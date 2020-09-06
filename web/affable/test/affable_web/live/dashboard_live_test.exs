defmodule AffableWeb.DashboardLiveTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Affable.SitesFixtures
  import Hammox

  alias Affable.Accounts

  setup :verify_on_exit!

  defp path(conn, site) do
    Routes.affiliate_sites_path(conn, :edit, site.id)
  end

  describe "authenticated user" do
    setup context do
      %{conn: conn, user: user} = register_and_log_in_user(context)
      %{conn: conn, user: user, site: site_fixture(user)}
    end

    test "redirects to login page when token is bogus", %{conn: conn, user: user, site: site} do
      Accounts.delete_user(user)

      conn = get(conn, "/dashboard")
      assert html_response(conn, 302)

      expected_path = Routes.user_session_path(conn, :new)

      {:error, {:redirect, %{to: actual_path}}} = live(conn, path(conn, site))

      assert actual_path == expected_path
    end

    test "shows spinner until site is available", %{} do
    end
  end

  describe "not authenticated" do
    test "redirects to login page", %{conn: conn} do
      conn = get(conn, "/dashboard")
      assert html_response(conn, 302)

      expected_path = Routes.user_session_path(conn, :new)

      {:error, {:redirect, %{to: actual_path}}} = live(conn, "/dashboard")

      assert actual_path == expected_path
    end
  end
end
