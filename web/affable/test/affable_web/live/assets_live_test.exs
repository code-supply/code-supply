defmodule AffableWeb.AssetsLiveTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Affable.AccountsFixtures

  alias Affable.Accounts

  describe "authenticated and confirmed user" do
    setup context do
      %{conn: conn, user: user} = register_and_log_in_user(context)

      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      Accounts.confirm_user(token)

      {:ok, %{conn: conn, user: user}}
    end
  end

  describe "authenticated, unconfirmed user" do
    setup context do
      register_and_log_in_user(context)
    end

    test "shows message until email is confirmed", %{conn: conn} do
      {:ok, _view, html} = live(conn, path(conn))

      assert html =~ "Check your email"
    end

    test "redirects to login page when token is bogus", %{conn: conn, user: user} do
      Accounts.delete_user(user)

      conn = get(conn, path(conn))
      assert html_response(conn, 302)

      expected_path = Routes.user_session_path(conn, :new)

      {:error, {:redirect, %{to: actual_path}}} = live(conn, path(conn))

      assert actual_path == expected_path
    end
  end

  describe "not authenticated" do
    test "redirects to login page", %{conn: conn} do
      conn = get(conn, path(conn))
      assert html_response(conn, 302)

      expected_path = Routes.user_session_path(conn, :new)

      {:error, {:redirect, %{to: actual_path}}} = live(conn, path(conn))

      assert actual_path == expected_path
    end
  end

  defp path(conn) do
    AffableWeb.Router.Helpers.assets_path(conn, :index)
  end
end
