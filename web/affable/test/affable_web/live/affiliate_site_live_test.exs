defmodule AffableWeb.AffiliateSitesLiveTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Affable.SitesFixtures

  alias Affable.Accounts

  setup do
    %{site: site_fixture()}
  end

  defp path(conn, site) do
    Routes.affiliate_sites_path(conn, :edit, site.id)
  end

  describe "not authenticated" do
    test "redirects to login page when not logged in", %{conn: conn, site: site} do
      conn = get(conn, path(conn, site))
      assert html_response(conn, 302)

      expected_path = Routes.user_session_path(conn, :new)

      {:error, {:redirect, %{to: actual_path}}} = live(conn, path(conn, site))

      assert actual_path == expected_path
    end
  end

  describe "authenticated user" do
    setup context do
      %{conn: conn, user: user} = register_and_log_in_user(context)
      %{conn: conn, user: user, site: site_fixture(user)}
    end

    test "redirects to login page when token is bogus", %{conn: conn, user: user, site: site} do
      Accounts.delete_user(user)

      conn = get(conn, path(conn, site))
      assert html_response(conn, 302)

      expected_path = Routes.user_session_path(conn, :new)

      {:error, {:redirect, %{to: actual_path}}} = live(conn, path(conn, site))

      assert actual_path == expected_path
    end

    test "raises exception when site doesn't belong to user", %{conn: conn} do
      site = site_fixture()

      assert_raise Ecto.NoResultsError, fn -> get(conn, path(conn, site)) end
    end

    test "can edit an item", %{conn: conn, site: site} do
      conn = get(conn, path(conn, site))
      assert html_response(conn, 200)

      {:ok, view, html} = live(conn, path(conn, site))

      [first_item | _] = site.items

      assert html =~ first_item.description

      assert render_first_item_change(view, site.items, %{
               "description" => "My new description!"
             }) =~ "My new description!"
    end

    test "editing an item to be invalid marks the item as invalid", %{conn: conn, site: site} do
      {:ok, view, _html} = live(conn, path(conn, site))

      assert render_first_item_change(view, site.items, %{
               "name" => ""
             }) =~ "phx-feedback-for=\"site_items_0_name"
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
end
