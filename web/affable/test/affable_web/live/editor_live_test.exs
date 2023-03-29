defmodule AffableWeb.EditorLiveTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Affable.SitesFixtures

  alias Affable.{Accounts, Sites}

  describe "authenticated user" do
    setup context do
      %{conn: conn, user: user} = register_and_log_in_user(context)
      [site] = user.sites

      %{
        conn: conn,
        user: user,
        site: site |> Sites.with_pages()
      }
    end

    test "raises exception when site doesn't belong to user", %{conn: conn} do
      site = site_fixture()

      assert_raise Ecto.NoResultsError, fn -> get(conn, test_path(conn, site)) end
    end

    test "redirects to login page when token is bogus", %{conn: conn, user: user, site: site} do
      Accounts.delete_user(user)

      conn = get(conn, test_path(conn, site))
      assert html_response(conn, 302)

      expected_path = ~p"/users/log_in"

      {:error, {:redirect, %{to: actual_path}}} = live(conn, test_path(conn, site))

      assert actual_path == expected_path
    end
  end

  describe "not authenticated" do
    setup do
      %{site: site_fixture()}
    end

    test "redirects to login page when not logged in", %{conn: conn, site: site} do
      conn = get(conn, test_path(conn, site))
      assert html_response(conn, 302)

      expected_path = ~p"/users/log_in"

      {:error, {:redirect, %{to: actual_path}}} = live(conn, test_path(conn, site))

      assert actual_path == expected_path
    end
  end

  defp test_path(conn, site) do
    Routes.editor_path(conn, :edit, site.id)
    |> control_plane_path()
  end
end
