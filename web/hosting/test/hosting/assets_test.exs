defmodule Hosting.AssetsTest do
  use Hosting.DataCase, async: true

  import Hosting.AccountsFixtures

  alias Hosting.Accounts.User
  alias Hosting.Assets
  alias Hosting.Assets.Asset
  alias Hosting.Sites.Site

  setup do
    %{wrong_user: %User{id: 9999}}
  end

  describe "assets" do
    test "can get an imgproxy URL for an Asset" do
      assert Assets.to_imgproxy_url(%Asset{url: "https://example.com/some-image.jpeg"}) =~
               ~r|https://hosting-images\.code\.supply/nosignature/fit/[0-9]+/[0-9]+/ce/0/plain/https://example\.com/some-image\.jpeg|
    end

    test "can specify resizing type" do
      assert Assets.to_imgproxy_url(%Asset{url: "https://example.com/some-image.jpeg"},
               width: 300,
               height: 300,
               resizing_type: "fit"
             ) ==
               "https://hosting-images.code.supply/nosignature/fit/300/300/ce/0/plain/https://example.com/some-image.jpeg"
    end

    test "can get an imgproxy URL for a URL" do
      assert Assets.to_imgproxy_url("https://example.com/some-image.jpeg",
               width: 400,
               height: 100
             ) ==
               "https://hosting-images.code.supply/nosignature/fit/400/100/ce/0/plain/https://example.com/some-image.jpeg"
    end

    test "can create multiple assets in a multi" do
      %User{sites: [site | _]} = user = user_fixture()

      multi =
        Ecto.Multi.new()
        |> Assets.create_uploaded_multi(
          user: user,
          bucket_name: "some-bucket",
          key: "my-key",
          params: %{
            "site_id" => site.id,
            "name" => "My asset"
          }
        )
        |> Assets.create_uploaded_multi(
          user: user,
          bucket_name: "some-bucket",
          key: "my-other-key",
          params: %{
            "site_id" => site.id,
            "name" => "My other asset"
          }
        )

      assert Enum.map(multi.operations, fn {name, _cs} -> name end) ==
               ~w(asset-my-other-key asset-my-key)
    end

    test "creates uploaded asset with source URL when name and site are given" do
      %User{sites: [site | _]} = user = user_fixture()

      {:ok, asset} =
        Assets.create_uploaded(
          user: user,
          bucket_name: "some-bucket",
          key: "my-key",
          params: %{
            "site_id" => site.id,
            "name" => "My asset"
          }
        )

      assert asset.name == "My asset"
      assert asset.url == "gs://some-bucket/my-key"
    end

    test "cannot create an asset without a name" do
      %User{sites: [site | _]} = user = user_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Assets.create_uploaded(
                 user: user,
                 bucket_name: "some-bucket",
                 key: "some-key",
                 params: %{"site_id" => site.id}
               )
    end

    test "cannot create asset for site when I'm not a team member", %{wrong_user: wrong_user} do
      %User{sites: [site | _]} = user_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Assets.create_uploaded(
                 user: wrong_user,
                 bucket_name: "some-bucket",
                 key: "hi-there",
                 params: %{
                   "site_id" => site.id,
                   "name" => "My asset"
                 }
               )
    end

    test "cannot create a Google Storage asset without a key" do
      %User{sites: [site | _]} = user = user_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Assets.create_uploaded(
                 user: user,
                 bucket_name: "some-bucket",
                 key: "",
                 params: %{"name" => "some name", "site_id" => site.id}
               )
    end

    test "can delete an asset" do
      %User{sites: [%Site{} = site | _]} = user = user_fixture()

      {:ok, asset} =
        Assets.create_uploaded(
          user: user,
          bucket_name: "foo",
          key: "bar",
          params: %{"site_id" => site.id, "name" => "new asset"}
        )

      count_before_delete =
        Repo.aggregate(from(a in Asset, where: [site_id: ^site.id]), :count, :id)

      {:ok, _} = Assets.delete(user, "#{asset.id}")

      assert Repo.aggregate(from(a in Asset, where: [site_id: ^site.id]), :count, :id) ==
               count_before_delete - 1
    end

    test "cannot delete an asset when I'm not a team member", %{wrong_user: wrong_user} do
      %User{sites: [%Site{} = site | _]} = user = user_fixture()

      {:ok, asset} =
        Assets.create_uploaded(
          user: user,
          bucket_name: "foo",
          key: "bar",
          params: %{"site_id" => site.id, "name" => "new asset"}
        )

      count_before_delete =
        Repo.aggregate(from(a in Asset, where: [site_id: ^site.id]), :count, :id)

      {:error, _} = Assets.delete(wrong_user, "#{asset.id}")

      assert Repo.aggregate(from(a in Asset, where: [site_id: ^site.id]), :count, :id) ==
               count_before_delete
    end
  end
end
