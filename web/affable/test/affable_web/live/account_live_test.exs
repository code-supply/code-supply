defmodule AffableWeb.AccountLiveTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Affable.Accounts

  defp path(conn) do
    Routes.live_path(conn, AffableWeb.AccountLive)
  end

  describe "not authenticated" do
    test "redirects to login page when not logged in", %{conn: conn} do
      conn = get(conn, path(conn))
      assert html_response(conn, 302)

      expected_path = Routes.user_session_path(conn, :new)

      {:error, {:redirect, %{to: actual_path}}} = live(conn, path(conn))

      assert actual_path == expected_path
    end
  end

  describe "authenticated" do
    setup :register_and_log_in_user

    test "redirects to login page when token is bogus", %{conn: conn, user: user} do
      Accounts.delete_user(user)

      conn = get(conn, path(conn))
      assert html_response(conn, 302)

      expected_path = Routes.user_session_path(conn, :new)

      {:error, {:redirect, %{to: actual_path}}} = live(conn, path(conn))

      assert actual_path == expected_path
    end
  end
end
