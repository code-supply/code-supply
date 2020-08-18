defmodule Affable.SitesTest do
  use Affable.DataCase

  import Affable.{AccountsFixtures, SitesFixtures}

  alias Affable.Sites
  alias Affable.Sites.{Site, SiteMember, Item}
  alias Affable.Domains.Domain

  describe "sites" do
    alias Affable.Sites.Site

    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    test "get_site!/2 returns the site with given user id and id" do
      user = user_fixture()
      site = site_fixture(user)
      assert Sites.get_site!(user, site.id) == site
    end

    test "get_site!/2 fails if user is incorrect" do
      user = user_fixture()
      site = site_fixture()

      assert_raise Ecto.NoResultsError, fn ->
        Sites.get_site!(user, site.id)
      end
    end

    test "new sites have a name, member, default domain and items" do
      user = user_fixture()
      site = site_fixture(user, %{name: "some name !@#!@#$@#%#$"})

      [%SiteMember{user_id: received_user_id}] = site.members
      [%Domain{name: domain_name}] = site.domains

      assert site.name == "some name !@#!@#$@#%#$"
      assert received_user_id == user.id
      assert domain_name == "site#{Affable.ID.encode(site.id)}.affable.app"

      assert [%Item{name: "Golden Delicious"} | rest] = site.items
      assert length(rest) == 9
    end

    test "create_site/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sites.create_site(user_fixture(), @invalid_attrs)
    end

    test "can demote an item" do
      site = site_fixture()
      [first_before | rest] = site.items
      [second_before | _] = rest

      assert first_before.position == 1
      assert second_before.position == 2

      {:ok, site} = Sites.demote_item(site, "#{first_before.id}")

      [first_after | rest] = site.items
      [second_after | _] = rest

      assert first_after.position == 1
      assert second_after.position == 2

      assert first_after.name == second_before.name
      assert second_after.name == first_before.name
    end

    test "demoting at the last position doesn't increase position number" do
      site = site_fixture()
      item = site.items |> List.last()

      assert item.position == 10

      {:ok, site} = Sites.demote_item(site, "#{item.id}")

      item_after = site.items |> List.last()

      assert item_after.position == 10
    end

    test "update_site/2 with valid data updates the site" do
      site = site_fixture()
      assert {:ok, %Site{} = site} = Sites.update_site(site, @update_attrs)
      assert site.name == "some updated name"
    end

    test "update_site/2 with invalid data returns error changeset" do
      user = user_fixture()
      site = site_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Sites.update_site(site, @invalid_attrs)
      assert site == Sites.get_site!(user, site.id)
    end

    test "delete_site/1 deletes the site" do
      user = user_fixture()
      site = site_fixture(user)
      assert {:ok, %Site{}} = Sites.delete_site(site)
      assert_raise Ecto.NoResultsError, fn -> Sites.get_site!(user, site.id) end
    end

    test "change_site/1 returns a site changeset" do
      site = site_fixture()
      assert %Ecto.Changeset{} = Sites.change_site(site)
    end
  end

  describe "items" do
    alias Affable.Sites.Item

    @valid_attrs %{
      description: "some description",
      image_url: "some image_url",
      name: "some name",
      position: 42,
      price: "120.5",
      url: "some url"
    }
    @update_attrs %{
      description: "some updated description",
      image_url: "some updated image_url",
      name: "some updated name",
      position: 43,
      price: "456.7",
      url: "some updated url"
    }
    @invalid_attrs %{
      description: nil,
      image_url: nil,
      name: nil,
      position: nil,
      price: nil,
      url: nil
    }

    def item_fixture(attrs \\ %{}) do
      {:ok, item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sites.create_item()

      item
    end

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert Sites.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Sites.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      assert {:ok, %Item{} = item} = Sites.create_item(@valid_attrs)
      assert item.description == "some description"
      assert item.image_url == "some image_url"
      assert item.name == "some name"
      assert item.position == 42
      assert item.price == Decimal.new("120.5")
      assert item.url == "some url"
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sites.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      assert {:ok, %Item{} = item} = Sites.update_item(item, @update_attrs)
      assert item.description == "some updated description"
      assert item.image_url == "some updated image_url"
      assert item.name == "some updated name"
      assert item.position == 43
      assert item.price == Decimal.new("456.7")
      assert item.url == "some updated url"
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Sites.update_item(item, @invalid_attrs)
      assert item == Sites.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Sites.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Sites.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Sites.change_item(item)
    end
  end
end
