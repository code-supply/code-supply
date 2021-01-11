defmodule Affable.AssetsTest do
  use Affable.DataCase, async: true

  import Affable.AccountsFixtures

  alias Affable.Assets
  alias Affable.Accounts.User

  describe "assets" do
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
      assert asset.url == "https://storage.cloud.google.com/some-bucket/my-key"
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

    test "cannot create asset for site when I'm not a team member" do
      %User{sites: [site | _]} = user_fixture()
      wrong_user = user_fixture()

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
  end
end
