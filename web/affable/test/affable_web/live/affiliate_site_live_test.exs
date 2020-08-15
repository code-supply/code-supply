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

  describe "authenticated" do
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

    test "lists items", %{conn: conn, site: site} do
      conn = get(conn, path(conn, site))
      assert html_response(conn, 200)

      {:ok, _view, html} = live(conn, path(conn, site))

      assert html =~ "<h1>#{site.name}</h1>"
    end
  end
end
