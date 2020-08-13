defmodule Affable.SitesTest do
  use Affable.DataCase

  import Affable.{AccountsFixtures, SitesFixtures}

  alias Affable.Sites
  alias Affable.Sites.{Site, SiteMember}
  alias Affable.Domains.Domain

  describe "sites" do
    alias Affable.Sites.Site

    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    test "get_site!/1 returns the site with given id" do
      site = site_fixture()
      assert Sites.get_site!(site.id) == site
    end

    test "new sites have a name, member and default domain" do
      user = user_fixture()
      site = site_fixture(user, %{name: "some name !@#!@#$@#%#$"})

      [%SiteMember{user_id: received_user_id}] = site.members
      [%Domain{name: domain_name}] = site.domains

      assert site.name == "some name !@#!@#$@#%#$"
      assert received_user_id == user.id
      assert domain_name == "site#{Affable.ID.encode(site.id)}.affable.app"
    end

    test "create_site/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sites.create_site(user_fixture(), @invalid_attrs)
    end

    test "update_site/2 with valid data updates the site" do
      site = site_fixture()
      assert {:ok, %Site{} = site} = Sites.update_site(site, @update_attrs)
      assert site.name == "some updated name"
    end

    test "update_site/2 with invalid data returns error changeset" do
      site = site_fixture()
      assert {:error, %Ecto.Changeset{}} = Sites.update_site(site, @invalid_attrs)
      assert site == Sites.get_site!(site.id)
    end

    test "delete_site/1 deletes the site" do
      site = site_fixture()
      assert {:ok, %Site{}} = Sites.delete_site(site)
      assert_raise Ecto.NoResultsError, fn -> Sites.get_site!(site.id) end
    end

    test "change_site/1 returns a site changeset" do
      site = site_fixture()
      assert %Ecto.Changeset{} = Sites.change_site(site)
    end
  end
end
