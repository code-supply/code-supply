defmodule AffableWeb.EditorLiveTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Affable.SitesFixtures
  import Hammox

  alias Affable.{Accounts, Layouts, Repo, Sites}
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

    test "can navigate back to site editing", %{conn: conn, site: site} do
      {:ok, view, _html} = live(conn, path(conn, site))

      view
      |> element("#site-choice a")
      |> render_click()

      assert view |> has_element?(~s{label[for="site_name"]})
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

    test "can choose layout", %{
      conn: conn,
      site: site
    } do
      {:ok, layout} = Layouts.create_layout(site, %{name: "basic"})
      {:ok, view, _html} = live(conn, path(conn, site))

      assert view
             |> has_element?("#site_layout_id option[value=#{layout.id}]")

      stub_broadcast()

      view
      |> render_change(:save, %{
        "site" => %{
          "layout_id" => "#{layout.id}"
        }
      })

      assert view
             |> has_element?("#site_layout_id option[value=#{layout.id}][selected]")
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
        pages: [
          %Page{
            items:
              [%Item{attributes: [%Attribute{id: first_attribute_id}]} = first_item | _] = items
          }
        ]
      } = Sites.get_site!(user, site.id)

      assert view
             |> has_element?("#site_attribute_definitions_0_name[value=Price]")

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
             |> has_element?("#site_attribute_definitions_0_name[value='Mattress Size']")

      view
      |> render_first_item_change(items, %{
        "attributes" => %{
          "0" => %{"id" => "#{first_attribute_id}", "value" => "King"}
        }
      })

      assert view
             |> has_element?("#item-#{first_item.id} [value=King]")
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

      view
      |> element("#page-choice-#{first_item.page_id} a")
      |> render_click()

      render_change(view |> element("#page-#{first_item.page_id}"), %{
        "page" => %{
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
