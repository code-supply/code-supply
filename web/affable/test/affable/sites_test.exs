defmodule Affable.SitesTest do
  use Affable.DataCase, async: true

  import Affable.{AccountsFixtures, SitesFixtures}
  import Affable.Sites.Raw
  import Access, only: [at: 1]
  import Hammox

  alias Affable.Accounts.User
  alias Affable.Assets
  alias Affable.Assets.Asset
  alias Affable.Sites
  alias Affable.Sites.{Page, Section, Site, SiteMember, Item, AttributeDefinition}
  alias Affable.Domains.Domain

  setup :verify_on_exit!

  describe "pages" do
    test "adding a page requires correct user, broadcasts result" do
      user = user_fixture()
      site = site_fixture(user)

      assert {:error, :unauthorized} = Sites.add_page(site, wrong_user())

      expect_broadcast(fn %Site{pages: [_ | [%Page{title: "Untitled page"}]]} -> nil end)
      assert {:ok, %Page{title: "Untitled page"}} = Sites.add_page(site, user)

      assert [%Page{} | [%Page{title: "Untitled page"}]] = Sites.get_site!(site.id).pages
    end

    test "updating a page broadcasts the result" do
      user = user_fixture()
      site = site_fixture(user)
      [page] = site.pages

      expect_broadcast(fn %Site{pages: [%Page{title: "my new title"}]} -> nil end)
      {:ok, page} = Sites.update_page(page, %{title: "my new title"}, user)

      assert "my new title" == page.title
    end

    test "can add multiple sections" do
      {page, user} = page_fixture()

      expect_broadcast(fn %Site{pages: [%Page{sections: [%Section{name: "New section"}]}]} ->
        nil
      end)

      {:ok, page} = Sites.add_page_section(page, user)

      expect_broadcast(fn %Site{pages: [%Page{sections: [_, %Section{name: "New section"}]}]} ->
        nil
      end)

      {:ok, page} = Sites.add_page_section(page, user)

      assert ["New section", "New section"] == Enum.map(page.sections, & &1.name)
    end

    test "updating a page with incorrect user is not allowed" do
      site = site_fixture()
      [%Page{title: old_title} = page] = site.pages

      assert {:error, :unauthorized} =
               Sites.update_page(page, %{title: "my new title"}, wrong_user())

      assert [%Page{title: ^old_title}] = Sites.get_site!(site.id).pages
    end

    test "deleting a page broadcasts the result" do
      user = user_fixture()
      %Site{pages: [page]} = site_fixture(user)
      expect_broadcast(fn %Site{pages: []} -> nil end)
      Sites.delete_page(page.id, user)
    end

    test "raw representation includes path" do
      assert %{"pages" => [%{"path" => "/contact"}]} =
               %{
                 unpersisted_site_fixture()
                 | pages: [%Page{path: "/contact", header_image: nil, items: []}]
               }
               |> raw()
    end
  end

  describe "sites" do
    alias Affable.Sites.Site

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
        site |> Sites.with_items() |> Sites.with_pages()
      }
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
      %{
        sites: [
          %Site{
            pages: [%Page{header_image: %Asset{url: header_image_url}}],
            publications: [publication]
          }
        ]
      } =
        user_fixture()
        |> Repo.preload(sites: [pages: [:header_image], publications: []])

      assert Assets.to_imgproxy_url(header_image_url,
               width: 567,
               height: 341,
               resizing_type: "fill"
             ) == get_in(publication.data, ["pages", at(0), "header_image_url"])
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

      %{pages: [page]} = published_again_site

      refute Sites.is_published?(%{published_again_site | pages: [%{page | header_text: "hi"}]})
    end

    test "raw representation copes with images being missing" do
      expected_logo_url = Assets.to_imgproxy_url("foo", width: 600, height: 176)

      expected_header_image_url =
        Assets.to_imgproxy_url("foo", width: 567, height: 341, resizing_type: "fill")

      assert %{
               "pages" => [%{"header_image_url" => nil}],
               "site_logo_url" => ^expected_logo_url
             } =
               raw(%Site{
                 site_logo: %Asset{url: "foo"},
                 pages: [%Page{header_image: nil, items: []}]
               })

      assert %{
               "pages" => [%{"header_image_url" => ^expected_header_image_url}],
               "site_logo_url" => nil
             } =
               raw(%Site{
                 pages: [%Page{header_image: %Asset{url: "foo"}, items: []}],
                 site_logo: nil
               })
    end

    test "raw representation includes item image URLs" do
      %{"pages" => [%{"items" => [%{"image_url" => raw_image_url}]}]} =
        raw(%Site{
          site_logo: nil,
          pages: [
            %Page{
              header_image: nil,
              items: [%Item{attributes: [], image: %Asset{url: "gs://some-bucket/image.jpg"}}]
            }
          ]
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
      site = site_fixture()

      assert_raise Ecto.NoResultsError, fn ->
        Sites.get_site!(wrong_user(), site.id)
      end
    end

    test "new sites have batteries-included defaults" do
      user = user_fixture()
      %Site{pages: [page]} = site = site_fixture(user, %{name: "some name !@#!@#$@#%#$"})

      [%SiteMember{user_id: received_user_id}] = site.members
      [%Domain{name: domain_name}] = site.domains

      assert site.name == "some name !@#!@#$@#%#$"
      assert site.internal_name =~ ~r/site[a-z0-9]+/
      assert site.internal_hostname =~ ~r/^app\.site[a-z0-9]+$/
      assert domain_name == "#{site.internal_name}.affable.app"
      assert received_user_id == user.id

      assert [%Item{name: "Golden Delicious"} | rest] = page.items
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

      definitions_before = site.attribute_definitions

      expect_broadcast(fn %Site{attribute_definitions: definitions} ->
        assert length(definitions) == length(definitions_before) + 1
      end)

      {:ok,
       %Site{attribute_definitions: [%AttributeDefinition{id: definition_id} = definition | _]}} =
        Sites.add_attribute_definition(site, user)

      {:error, _} = Sites.add_attribute_definition(site, wrong_user())

      %Site{pages: [%Page{items: [first_item | _]}]} = Sites.get_site!(site.id)

      assert definition_id in (first_item.attributes |> Enum.map(& &1.definition_id))

      {:error, _} = Sites.delete_attribute_definition(site.id, definition.id, wrong_user())
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
      %Site{pages: [%Page{items: [item | _]} = page_before]} = site = site_fixture(user)

      expect_broadcast(fn site ->
        [page] = site.pages
        [published_page] = site.latest_publication.data["pages"]
        assert length(published_page["items"]) - 1 == length(page.items)
      end)

      {:ok, %Page{} = page_after} = Sites.delete_item(site, page_before, "#{item.id}")

      positions_after =
        page_after.items
        |> Enum.map(fn i -> i.position end)

      assert length(page_before.items) - 1 == length(page_after.items)

      assert 1..length(page_after.items) |> Enum.into([]) == positions_after

      %Site{pages: [page_reloaded]} = Sites.get_site!(site.id)

      assert Enum.map(page_after.items, & &1.id) == Enum.map(page_reloaded.items, & &1.id)
    end

    test "can delete an item from end of list" do
      user = user_fixture()
      %Site{pages: [%Page{items: items} = page_before]} = site = site_fixture(user)

      expect_broadcast(fn site ->
        [page] = site.pages
        [published_page] = site.latest_publication.data["pages"]
        assert length(published_page["items"]) - 1 == length(page.items)
      end)

      {:ok, %Page{} = page_after} = Sites.delete_item(site, page_before, "#{List.last(items).id}")

      positions_after =
        page_after.items
        |> Enum.map(fn i -> i.position end)

      assert length(page_before.items) - 1 == length(page_after.items)

      assert 1..length(page_after.items) |> Enum.into([]) == positions_after

      %Site{pages: [page_reloaded]} = Sites.get_site!(site.id)

      assert Enum.map(page_after.items, & &1.id) == Enum.map(page_reloaded.items, & &1.id)
    end

    test "can demote an item" do
      %Site{pages: [page]} = site = site_fixture()

      [first_before | rest] = page.items
      [second_before | _] = rest

      assert first_before.position == 1
      assert second_before.position == 2

      expect_broadcast(fn s ->
        [page] = s.pages
        [published_page] = s.latest_publication.data["pages"]
        assert Enum.map(page.items, & &1.name) != Enum.map(published_page["items"], & &1["name"])
      end)

      {:ok, %Site{pages: [page]}} = Sites.demote_item(site, page, "#{first_before.id}")

      [first_after | rest] = page.items
      [second_after | _] = rest

      assert first_after.position == 1
      assert second_after.position == 2

      assert first_after.name == second_before.name
      assert second_after.name == first_before.name
    end

    test "demoting at the last position doesn't increase position number" do
      %Site{pages: [page]} = site = site_fixture()

      item = page.items |> List.last()

      assert item.position == 10

      {:ok, %Site{pages: [page]}} = Sites.demote_item(site, page, "#{item.id}")

      item_after = page.items |> List.last()

      assert item_after.position == 10
    end

    test "can promote an item" do
      %Site{pages: [page]} = site = site_fixture()

      [first_before | rest] = page.items
      [second_before | _] = rest

      assert first_before.position == 1
      assert second_before.position == 2

      stub_broadcast()

      {:ok, %Site{pages: [page]}} = Sites.promote_item(site, page, "#{second_before.id}")

      [first_after | rest] = page.items
      [second_after | _] = rest

      assert first_after.position == 1
      assert second_after.position == 2

      assert first_after.name == second_before.name
      assert second_after.name == first_before.name
    end

    test "promoting at the first position doesn't decrease position number" do
      %Site{pages: [page]} = site = site_fixture()

      [item | _] = page.items

      assert item.position == 1

      {:ok, %Site{pages: [page]}} = Sites.promote_item(site, page, "#{item.id}")

      [item_after | _] = page.items

      assert item_after.position == 1
    end

    test "update_site/2 with valid data updates the site" do
      {_, site} = user_and_site_with_items()

      %Site{pages: [%Page{header_image: %Asset{id: header_image_id, url: expected_asset_url}}]} =
        site |> Repo.preload(pages: [:header_image])

      expect_broadcast(fn %Site{
                            name: "some updated name",
                            site_logo: %Asset{url: broadcast_asset_url}
                          } ->
        assert broadcast_asset_url == expected_asset_url
      end)

      [definition] = site.attribute_definitions

      assert {:ok, %Site{pages: [updated_page]} = updated_site} =
               Sites.update_site(site, %{
                 "name" => "some updated name",
                 "site_logo_id" => header_image_id,
                 "attribute_definitions" => %{
                   "0" => %{
                     "id" => "#{definition.id}",
                     "name" => "some updated attribute name"
                   }
                 }
               })

      assert updated_site.name == "some updated name"

      [definition] = updated_site.attribute_definitions
      assert "some updated attribute name" == definition.name

      [item | _] = updated_page.items
      [attribute | _] = item.attributes
      assert "some updated attribute name" == attribute.definition.name
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

    test "append_item/2 adds a default item to the end of the items list" do
      {user, %Site{pages: [page]} = site} = user_and_site_with_items()

      expect_broadcast(fn %Site{pages: [%Page{items: items}]} ->
        assert %{"name" => "New item"} = raw(items |> List.last())
      end)

      {:ok, %Site{pages: [%Page{items: appended_site_items}]}, _appended_item} =
        Sites.append_item(site, page, user)

      {:error, :unauthorized} = Sites.append_item(site, page, wrong_user())

      %Site{pages: [%Page{items: items}]} = Sites.get_site!(site.id)
      retrieved_item = List.last(items)

      appended_item = List.last(appended_site_items)
      assert appended_item == retrieved_item
      assert retrieved_item.name == "New item"
      assert length(retrieved_item.attributes) > 0
    end
  end

  defp wrong_user do
    %User{id: 99_999}
  end
end
