defmodule Affable.AssetsTest do
  use Affable.DataCase, async: true

  import Affable.AccountsFixtures

  alias Affable.Assets
  alias Affable.Assets.Asset
  alias Affable.Accounts.User

  describe "assets" do
    test "cannot create an asset without a name" do
      %User{sites: [site | _]} = user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Assets.create(user, %{"site_id" => site.id})
    end

    test "creates asset when name and site given" do
      %User{sites: [site | _]} = user = user_fixture()
      assert {:ok, %Asset{}} = Assets.create(user, %{"site_id" => site.id, "name" => "My asset"})
    end

    test "cannot create asset for site when I'm not a team member" do
      %User{sites: [site | _]} = user_fixture()
      wrong_user = user_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Assets.create(wrong_user, %{"site_id" => site.id, "name" => "My asset"})
    end
  end
end
