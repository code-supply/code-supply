defmodule AffableWeb.SitesLiveTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Affable.Accounts
  alias Affable.Accounts.User
  alias Affable.Sites

  describe "authenticated user" do
    setup context do
      register_and_log_in_user(context)
    end

    test "redirects to login page when token is bogus", %{conn: conn, user: user} do
      Accounts.delete_user(user)

      conn = get(conn, "/sites")
      assert html_response(conn, 302)

      expected_path = Routes.user_session_path(conn, :new)

      {:error, {:redirect, %{to: actual_path}}} = live(conn, path(conn))

      assert actual_path == expected_path
    end

    test "shows spinner until site is available", %{conn: conn, user: %User{sites: [site]}} do
      {:ok, view, _html} = live(conn, path(conn))

      assert view |> has_element?(".pending")

      Phoenix.PubSub.broadcast(:affable, site.internal_name, %{
        Sites.raw(site |> Affable.Repo.preload(:items))
        | made_available_at: DateTime.utc_now()
      })

      refute view |> has_element?(".pending")
      assert view |> has_element?(".available")
    end
  end

  describe "not authenticated" do
    test "redirects to login page", %{conn: conn} do
      conn = get(conn, "/sites")
      assert html_response(conn, 302)

      expected_path = Routes.user_session_path(conn, :new)

      {:error, {:redirect, %{to: actual_path}}} = live(conn, path(conn))

      assert actual_path == expected_path
    end
  end

  defp path(conn) do
    AffableWeb.Router.Helpers.sites_path(conn, :index)
  end
end
