defmodule AffableWeb.EditorLiveTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Affable.SitesFixtures
  import Hammox

  alias Affable.Assets.Asset
  alias Affable.{Repo, Accounts, Sites}
  alias Affable.Sites.{Page, Site, Item, Attribute}

  setup :verify_on_exit!

  defp path(conn, site) do
    Routes.editor_path(conn, :edit, site.id)
  end

  describe "authenticated user" do
    setup context do
      %{conn: conn, user: user} = register_and_log_in_user(context)
      [site] = user.sites

      %{
        conn: conn,
        user: user,
        site: site |> Sites.with_items() |> Sites.with_pages()
      }
    end

    test "can set header properties for first page", %{conn: conn, site: site} do
      {:ok, view, _html} = live(conn, path(conn, site))

      [%Page{id: first_page_id}] = (site |> Repo.preload(:pages)).pages

      expect_broadcast(fn %Site{pages: [%Page{header_text: header_text} | _]} ->
        assert "new header text" == header_text
      end)

      view
      |> element("#page_#{first_page_id}")
      |> render_change(%{page: %{header_text: "new header text"}})

      assert view |> has_element?("#publish")

      expect_broadcast(fn %Site{pages: [%Page{header_text: header_text} | _]} ->
        assert "new header text" == header_text
      end)

      view
      |> element("#new-item-top")
      |> render_click()

      conn = get(conn, path(conn, site))
      assert conn.resp_body =~ "new header text"
    end

    test "can publish the changes", %{
      conn: conn,
      site: site
    } do
      {:ok, view, _html} = live(conn, path(conn, site))

      attribute_definitions_before =
        Repo.preload(site, :attribute_definitions).attribute_definitions

      refute view
             |> has_element?("#publish")

      stub_broadcast()

      view
      |> element("#new-attribute-definition")
      |> render_click()

      assert view
             |> has_element?("#publish")

      expect_broadcast(fn updated_site ->
        assert length(updated_site.attribute_definitions) ==
                 length(attribute_definitions_before) + 1
      end)

      view
      |> element("#publish")
      |> render_click()

      refute view
             |> has_element?("#publish")
    end

    test "can create / update / delete an attribute definition", %{
      conn: conn,
      user: user,
      site: site
    } do
      {:ok, view, _html} = live(conn, path(conn, site))

      %Site{attribute_definitions: [existing_definition]} =
        site |> Affable.Repo.preload(:attribute_definitions)

      stub_broadcast()

      view
      |> element("#delete-attribute-definition-#{existing_definition.id}")
      |> render_click()

      refute view
             |> has_element?(".attribute-definition:nth-child(1)")

      view
      |> element("#new-attribute-definition")
      |> render_click()

      %Site{
        attribute_definitions: [new_definition],
        items: [%Item{attributes: [%Attribute{id: first_attribute_id}]} | _] = items
      } = Sites.get_site!(user, site.id)

      assert view
             |> has_element?("#item-edit_attribute_definitions_0_name[value=Price]")

      view
      |> render_change(:save, %{
        "site" => %{
          "attribute_definitions" => %{
            "0" => %{
              "id" => "#{new_definition.id}",
              "name" => "Mattress Size",
              "type" => "text"
            }
          }
        }
      })

      assert view
             |> has_element?("#item-edit_attribute_definitions_0_name[value='Mattress Size']")

      view
      |> render_first_item_change(items, %{
        "attributes" => %{
          "0" => %{"id" => "#{first_attribute_id}", "value" => "King"}
        }
      })

      assert view
             |> has_element?("#item-edit_items_0_attributes_0_value[value=King]")
    end

    test "can create / delete new item", %{conn: conn, site: site} do
      {:ok, view, _html} = live(conn, path(conn, site))

      num_items = site.items |> length()

      refute view
             |> has_element?(".item:nth-child(#{num_items + 1})")

      stub_broadcast()

      view
      |> element("#new-item-top")
      |> render_click()

      site = Sites.get_site!(site.id)

      assert site.items
             |> length() == num_items + 1

      assert view
             |> has_element?(".item:nth-child(2) .number", "2")

      assert view
             |> has_element?(".item:nth-child(#{num_items + 1})")

      view
      |> element("#delete-item-#{List.last(site.items).id}")
      |> render_click()

      assert view
             |> element(".item:nth-child(1) .number")
             |> render() =~
               ">1<"
    end

    test "can edit an item", %{
      conn: conn,
      site: %Site{pages: [%Page{header_image_id: header_image_id}]} = site
    } do
      conn = get(conn, path(conn, site))
      assert html_response(conn, 200)

      {:ok, view, html} = live(conn, path(conn, site))

      [first_item | _] = site.items

      first_image_url = first_item.image.url

      assert first_image_url =~ "gs://"

      assert html =~ first_item.description

      copied_asset_id = header_image_id

      expect_broadcast(fn %Site{
                            items: [
                              %Item{
                                description: "My new description!",
                                image: %Asset{id: received_asset_id}
                              }
                              | _
                            ]
                          } ->
        assert received_asset_id == copied_asset_id
      end)

      assert render_first_item_change(view, site.items, %{
               "description" => "My new description!",
               "image_id" => "#{copied_asset_id}"
             }) =~ "My new description!"
    end

    @tag :capture_log
    test "editing an item to be invalid marks the item as invalid", %{conn: conn, site: site} do
      {:ok, view, _html} = live(conn, path(conn, site))

      result =
        render_first_item_change(view, site.items, %{
          "name" => ""
        })

      assert result =~ "phx-feedback-for=\"item-edit_items_0_name"
    end

    test "can delete an item", %{conn: conn, site: site} do
      {:ok, view, _html} = live(conn, path(conn, site))

      [first_item | _] = site.items

      stub_broadcast()

      view
      |> element("#delete-item-#{first_item.id}")
      |> render_click()

      refute view |> has_element?("#delete-item-#{first_item.id}")
    end

    test "can reorder an item", %{conn: conn, site: site} do
      {:ok, view, _html} = live(conn, path(conn, site))

      [first_item | _] = site.items

      assert view |> has_element?("#item-#{first_item.id} .number", "1")

      stub_broadcast()

      view
      |> element("#demote-#{first_item.id}")
      |> render_click()

      assert view |> has_element?("#item-#{first_item.id} .number", "2")

      view
      |> element("#promote-#{first_item.id}")
      |> render_click()

      assert view |> has_element?("#item-#{first_item.id} .number", "1")
    end

    test "reordering broadcasts the change to the site", %{conn: conn, site: site} do
      {:ok, view, _html} = live(conn, path(conn, site))

      [first_item | _] = site.items

      expect_broadcast(fn %Site{items: [_, new_second_item | _]} ->
        assert first_item.name == new_second_item.name
      end)

      view
      |> element("#demote-#{first_item.id}")
      |> render_click()

      expect_broadcast(fn %Site{items: [new_first_item | _]} ->
        assert first_item.name == new_first_item.name
      end)

      view
      |> element("#promote-#{first_item.id}")
      |> render_click()
    end

    test "raises exception when site doesn't belong to user", %{conn: conn} do
      site = site_fixture()

      assert_raise Ecto.NoResultsError, fn -> get(conn, path(conn, site)) end
    end

    test "redirects to login page when token is bogus", %{conn: conn, user: user, site: site} do
      Accounts.delete_user(user)

      conn = get(conn, path(conn, site))
      assert html_response(conn, 302)

      expected_path = Routes.user_session_path(conn, :new)

      {:error, {:redirect, %{to: actual_path}}} = live(conn, path(conn, site))

      assert actual_path == expected_path
    end

    defp render_first_item_change(view, items, attrs) do
      [first_item | other_items] = items

      render_change(view, :save, %{
        "_method" => "put",
        "_target" => ["site", "items", "0", "name"],
        "site" => %{
          "items" =>
            Map.merge(
              %{
                "0" =>
                  Map.merge(
                    %{
                      "id" => "#{first_item.id}",
                      "name" => first_item.name,
                      "description" => first_item.description
                    },
                    attrs
                  )
              },
              item_params(other_items, from: 1)
            )
        }
      })
    end

    defp item_params([], from: _n) do
      %{}
    end

    defp item_params([item | items], from: n) do
      Map.merge(
        %{
          "#{n}" => %{
            "id" => "#{item.id}",
            "name" => "#{item.name}",
            "description" => "#{item.description}"
          }
        },
        item_params(items, from: n + 1)
      )
    end
  end

  describe "not authenticated" do
    setup do
      %{site: site_fixture()}
    end

    test "redirects to login page when not logged in", %{conn: conn, site: site} do
      conn = get(conn, path(conn, site))
      assert html_response(conn, 302)

      expected_path = Routes.user_session_path(conn, :new)

      {:error, {:redirect, %{to: actual_path}}} = live(conn, path(conn, site))

      assert actual_path == expected_path
    end
  end
end
