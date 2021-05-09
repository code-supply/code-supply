defmodule Affable.SitesTest do
  use Affable.DataCase, async: true

  import Affable.{AccountsFixtures, SitesFixtures}
  import Affable.Sites.Raw
  import Hammox

  alias Affable.Accounts.User
  alias Affable.Assets
  alias Affable.Assets.Asset
  alias Affable.Sites
  alias Affable.Sites.{Site, SiteMember, Item, AttributeDefinition}
  alias Affable.Domains.Domain

  setup :verify_on_exit!

  describe "sites" do
    alias Affable.Sites.Site

    @valid_site %Site{name: "hi", cta_text: "Go"}
    @invalid_attrs %{name: nil}

    setup do
      Hammox.protect(
        Sites,
        Affable.SiteClusterIO,
        get_site!: 1,
        set_available: 2
      )
    end

    defp user_and_site_with_items() do
      %User{sites: [site]} = user = unconfirmed_user_fixture()

      {
        user,
        site |> Sites.with_items()
      }
    end

    test "colours can be set to valid values" do
      changeset =
        @valid_site
        |> Site.changeset(%{cta_background_colour: "EEFF20", cta_text_colour: "012345"})

      assert changeset.errors == []
      assert changeset.changes.cta_background_colour == "EEFF20"
      assert changeset.changes.cta_text_colour == "012345"
    end

    test "colours can't be set to invalid values" do
      changeset =
        @valid_site
        |> Site.changeset(%{cta_background_colour: "01234", cta_text_colour: "GGGGGG"})

      assert {_, validation: :format} = changeset.errors[:cta_background_colour]
      assert {_, validation: :format} = changeset.errors[:cta_text_colour]
    end

    test "CTA attributes can't be blank" do
      changeset =
        @valid_site
        |> Site.changeset(%{cta_text: "", cta_background_colour: "", cta_text_colour: " "})

      assert {_, validation: :required} = changeset.errors[:cta_text]
      assert {_, validation: :required} = changeset.errors[:cta_background_colour]
      assert {_, validation: :required} = changeset.errors[:cta_text_colour]
    end

    test "status of new site is pending" do
      assert %Site{}
             |> Sites.status() == :pending
    end

    test "preview URL chooses affable domain" do
      assert "//something.affable.app/preview" ==
               %Site{
                 domains: [
                   %Domain{name: "something.affable.app"},
                   %Domain{name: "my.domain.example.com"}
                 ]
               }
               |> Sites.preview_url()
    end

    test "preview URL chooses only domain if there are no affable ones" do
      assert "//my.domain.example.com/preview" ==
               %Site{
                 domains: [
                   %Domain{name: "my.domain.example.com"}
                 ]
               }
               |> Sites.preview_url()
    end

    test "canonical URL with a single domain uses that domain" do
      assert "//something.affable.app/" ==
               %Site{domains: [%Domain{name: "something.affable.app"}]}
               |> Sites.canonical_url()
    end

    test "canonical URL with a custom domain is the custom domain" do
      assert "//my.domain.example.com/" ==
               %Site{
                 domains: [
                   %Domain{name: "something.affable.app"},
                   %Domain{name: "my.domain.example.com"}
                 ]
               }
               |> Sites.canonical_url()
    end

    test "status of site that's been made available once is available, and doesn't update date subsequently",
         %{
           set_available_2: set_available
         } do
      site = site_fixture()

      first_made_available_at = DateTime.from_unix!(0)

      {:ok, site} = set_available.(site.id, first_made_available_at)

      assert site |> Sites.status() == :available

      {:ok, site} = set_available.(site.id, DateTime.from_unix!(1))
      assert site.made_available_at == first_made_available_at
    end

    test "setting as available preloads domains, so the live sites view can render them", %{
      set_available_2: set_available
    } do
      site = site_fixture()

      first_made_available_at = DateTime.from_unix!(0)

      {:ok, site} = set_available.(site.id, first_made_available_at)

      assert site.domains |> length == 1
    end

    test "sites start with a publication" do
      %{sites: [%Site{header_image: %Asset{url: header_image_url}, publications: [publication]}]} =
        user_fixture() |> Repo.preload(sites: [:header_image, :publications])

      assert publication.data["header_image_url"] ==
               Assets.to_imgproxy_url(header_image_url,
                 width: 567,
                 height: 341,
                 resizing_type: "fill"
               )
    end

    test "site is published when latest publication is same as current raw representation", %{
      set_available_2: set_available
    } do
      %User{sites: [site]} = user_fixture()

      {:ok, site} = set_available.(site.id, DateTime.from_unix!(0))

      refute Sites.is_published?(site)

      expect_broadcast(fn site ->
        assert Sites.is_published?(site)
      end)

      {:ok, published_site} = Sites.publish(site)

      assert Sites.is_published?(published_site)

      expect_broadcast(fn %Site{} -> nil end)
      {:ok, published_again_site} = Sites.publish(site)

      assert Sites.is_published?(published_again_site)
    end

    test "raw representation copes with one or other images being missing" do
      expected_logo_url = Assets.to_imgproxy_url("foo", width: 600, height: 176)

      expected_header_image_url =
        Assets.to_imgproxy_url("foo", width: 567, height: 341, resizing_type: "fill")

      assert %{"header_image_url" => nil, "site_logo_url" => ^expected_logo_url} =
               raw(%Site{site_logo: %Asset{url: "foo"}, header_image: nil, items: []})

      assert %{"header_image_url" => ^expected_header_image_url, "site_logo_url" => nil} =
               raw(%Site{header_image: %Asset{url: "foo"}, site_logo: nil, items: []})
    end

    test "raw representation includes item image URLs" do
      %{"items" => [%{"image_url" => raw_image_url}]} =
        raw(%Site{
          site_logo: nil,
          header_image: nil,
          items: [%Item{attributes: [], image: %Asset{url: "gs://some-bucket/image.jpg"}}]
        })

      assert raw_image_url =~ "https://images.affable.app"
    end

    test "get_site!/1 preloads latest publication" do
      site = site_fixture()
      assert Sites.get_site!(site.id).latest_publication.data
    end

    test "get_site!/2 returns the site with given user id and id" do
      user = user_fixture()
      site = site_fixture(user)
      assert Sites.get_site!(user, site.id).id == site.id
    end

    test "get_site!/2 fails if user is incorrect" do
      user = user_fixture()
      site = site_fixture()

      assert_raise Ecto.NoResultsError, fn ->
        Sites.get_site!(user, site.id)
      end
    end

    test "new sites have batteries-included defaults" do
      user = user_fixture()
      site = site_fixture(user, %{name: "some name !@#!@#$@#%#$"})

      [%SiteMember{user_id: received_user_id}] = site.members
      [%Domain{name: domain_name}] = site.domains

      assert site.name == "some name !@#!@#$@#%#$"
      assert site.internal_name =~ ~r/site[a-z0-9]+/
      assert site.internal_hostname =~ ~r/^app\.site[a-z0-9]+$/
      assert domain_name == "#{site.internal_name}.affable.app"
      assert received_user_id == user.id

      assert [%Item{name: "Golden Delicious"} | rest] = site.items
      assert length(rest) == 9

      assert Sites.is_published?(site)
    end

    test "create_site/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sites.create_site(user_fixture(), @invalid_attrs)
    end

    test "there is a finite set of attribute types" do
      definition = %AttributeDefinition{name: "validname"}

      has_valid = fn definition, attr, ty ->
        AttributeDefinition.changeset(definition, %{attr => ty}).valid?
      end

      refute definition |> has_valid.(:type, "bad-type")
      assert definition |> has_valid.(:type, "dollar")
      assert definition |> has_valid.(:type, "pound")
      assert definition |> has_valid.(:type, "euro")
      assert definition |> has_valid.(:type, "number")
      assert definition |> has_valid.(:type, "text")
    end

    test "site members can manage attribute definitions" do
      {user, site} = user_and_site_with_items()
      wrong_user = user_fixture()

      definitions_before = site.attribute_definitions

      expect_broadcast(fn %Site{attribute_definitions: definitions} ->
        assert length(definitions) == length(definitions_before) + 1
      end)

      {:ok,
       %Site{attribute_definitions: [%AttributeDefinition{id: definition_id} = definition | _]}} =
        Sites.add_attribute_definition(site, user)

      {:error, _} = Sites.add_attribute_definition(site, wrong_user)

      [first_item | _] = Sites.get_site!(user, site.id).items

      assert definition_id in (first_item.attributes |> Enum.map(& &1.definition_id))

      {:error, _} = Sites.delete_attribute_definition(site.id, definition.id, wrong_user)
      assert [definition | _] = Sites.get_site!(user, site.id).attribute_definitions

      expect_broadcast(fn %Site{attribute_definitions: definitions} ->
        assert length(definitions) == length(definitions_before)
      end)

      {:ok, _} = Sites.delete_attribute_definition(site.id, definition.id, user)

      assert Sites.get_site!(user, site.id).attribute_definitions ==
               definitions_before
    end

    test "can delete an item from start of list" do
      user = user_fixture()
      site_before = site_fixture(user)

      expect_broadcast(fn %Site{
                            items: preview_items,
                            latest_publication: %{data: %{"items" => published_items}}
                          } ->
        assert preview_items |> length() == (published_items |> length()) - 1
      end)

      {:ok, site_after} = Sites.delete_item(site_before, "#{Enum.at(site_before.items, 1).id}")

      positions_after =
        site_after.items
        |> Enum.map(fn i -> i.position end)

      assert length(site_after.items) ==
               length(site_before.items) - 1

      assert positions_after ==
               1..length(site_after.items) |> Enum.into([])

      assert Enum.map(Sites.get_site!(user, site_before.id).items, & &1.id) ==
               Enum.map(site_after.items, & &1.id)
    end

    test "can delete an item from end of list" do
      user = user_fixture()
      site_before = site_fixture(user)

      expect_broadcast(fn %Site{
                            items: preview_items,
                            latest_publication: %{data: %{"items" => published_items}}
                          } ->
        assert preview_items |> length() == (published_items |> length()) - 1
      end)

      {:ok, site_after} = Sites.delete_item(site_before, "#{List.last(site_before.items).id}")

      positions_after =
        site_after.items
        |> Enum.map(fn i -> i.position end)

      assert length(site_after.items) ==
               length(site_before.items) - 1

      assert positions_after ==
               1..length(site_after.items) |> Enum.into([])

      assert Enum.map(Sites.get_site!(user, site_before.id).items, & &1.id) ==
               Enum.map(site_after.items, & &1.id)
    end

    test "can demote an item" do
      {user, site} = user_and_site_with_items()

      [first_before | rest] = site.items
      [second_before | _] = rest

      assert first_before.position == 1
      assert second_before.position == 2

      expect_broadcast(fn %Site{
                            items: preview_items,
                            latest_publication: %{data: %{"items" => published_items}}
                          } ->
        assert preview_items != published_items
      end)

      {:ok, site} = Sites.demote_item(user, site, "#{first_before.id}")

      [first_after | rest] = site.items
      [second_after | _] = rest

      assert first_after.position == 1
      assert second_after.position == 2

      assert first_after.name == second_before.name
      assert second_after.name == first_before.name
    end

    test "demoting at the last position doesn't increase position number" do
      {user, site} = user_and_site_with_items()

      item = site.items |> List.last()

      assert item.position == 10

      {:ok, site} = Sites.demote_item(user, site, "#{item.id}")

      item_after = site.items |> List.last()

      assert item_after.position == 10
    end

    test "can promote an item" do
      {user, site} = user_and_site_with_items()

      [first_before | rest] = site.items
      [second_before | _] = rest

      assert first_before.position == 1
      assert second_before.position == 2

      stub_broadcast()

      {:ok, site} = Sites.promote_item(user, site, "#{second_before.id}")
      {:error, _} = Sites.promote_item(user_fixture(), site, "#{second_before.id}")

      [first_after | rest] = site.items
      [second_after | _] = rest

      assert first_after.position == 1
      assert second_after.position == 2

      assert first_after.name == second_before.name
      assert second_after.name == first_before.name
    end

    test "promoting at the first position doesn't decrease position number" do
      {user, site} = user_and_site_with_items()

      [item | _] = site.items

      assert item.position == 1

      {:ok, site} = Sites.promote_item(user, site, "#{item.id}")

      [item_after | _] = site.items

      assert item_after.position == 1
    end

    test "update_site/2 with valid data updates the site" do
      {user, site} = user_and_site_with_items()
      site = site |> Repo.preload(:header_image)

      expected_asset_url = site.header_image.url

      expect_broadcast(fn %Site{
                            name: "some updated name",
                            site_logo: %Asset{url: broadcast_asset_url}
                          } ->
        assert broadcast_asset_url == expected_asset_url
      end)

      [definition] = site.attribute_definitions

      site_as_live_view = Sites.get_site!(user, site.id)

      assert {:ok, %Site{} = updated_site} =
               Sites.update_site(site_as_live_view, %{
                 "name" => "some updated name",
                 "site_logo_id" => site.header_image_id,
                 "cta_text_colour" => "f0f0f0",
                 "cta_background_colour" => "eEfF01",
                 "attribute_definitions" => %{
                   "0" => %{
                     "id" => "#{definition.id}",
                     "name" => "some updated attribute name"
                   }
                 }
               })

      assert updated_site.name == "some updated name"
      assert updated_site.cta_background_colour == "EEFF01"
      assert updated_site.cta_text_colour == "F0F0F0"

      [definition] = updated_site.attribute_definitions
      assert definition.name == "some updated attribute name"

      [item | _] = updated_site.items
      [attribute | _] = item.attributes
      assert attribute.definition.name == "some updated attribute name"
    end

    test "update_site/2 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sites.update_site(site_fixture(), @invalid_attrs)
    end

    test "delete_site/1 deletes the site" do
      %User{sites: [site]} = user = user_fixture()
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
      name: "some name",
      position: 42,
      url: "some url"
    }
    @update_attrs %{
      description: "some updated description",
      name: "some updated name",
      position: 43,
      url: "some updated url"
    }
    @invalid_attrs %{
      description: nil,
      name: nil,
      position: nil,
      price: nil,
      url: nil
    }

    def item_fixture(attrs \\ %{}) do
      {:ok, item} =
        Sites.create_item(
          site_fixture(),
          attrs
          |> Enum.into(@valid_attrs)
        )

      item
    end

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert Sites.list_items() |> Enum.member?(item)
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Sites.get_item!(item.id) == item
    end

    test "create_item/2 with valid data creates a item" do
      assert {:ok, %Item{} = item} = Sites.create_item(site_fixture(), @valid_attrs)

      assert item.description == "some description"
      assert item.name == "some name"
      assert item.position == 42
      assert item.url == "some url"
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sites.create_item(site_fixture(), @invalid_attrs)
    end

    test "append_item/2 adds a default item to the end of the items list" do
      {user, site} = user_and_site_with_items()

      expect_broadcast(fn %{items: items} ->
        assert %{"name" => "New item"} = raw(items |> List.last())
      end)

      {:ok, appended_site} = Sites.append_item(site, user)

      {:error, :unauthorized} = Sites.append_item(site, user_fixture())

      site = Sites.get_site!(site.id)
      retrieved_item = List.last(site.items)

      appended_item = List.last(appended_site.items)
      assert appended_item == retrieved_item
      assert retrieved_item.name == "New item"
      assert length(retrieved_item.attributes) > 0
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      assert {:ok, %Item{} = item} = Sites.update_item(item, @update_attrs)
      assert item.description == "some updated description"
      assert item.name == "some updated name"
      assert item.position == 43
      assert item.url == "some updated url"
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Sites.update_item(item, @invalid_attrs)
      assert item == Sites.get_item!(item.id)
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Sites.change_item(item)
    end
  end
end
