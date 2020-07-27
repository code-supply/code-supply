defmodule AccountLiveTest do
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

    test "entering a valid domain adds it to the list", %{conn: conn} do
      conn = get(conn, path(conn))

      {:ok, view, html} = live(conn, path(conn))

      refute html =~ "foo.com"

      assert view
             |> form("#create-domain", %{"domain" => %{"name" => "foo.com"}})
             |> render_submit() =~ "foo.com</li>"
    end

    test "entering an invalid domain shows an error and clears the change", %{conn: conn} do
      conn = get(conn, path(conn))

      {:ok, view, _html} = live(conn, path(conn))

      assert view
             |> form("#create-domain", %{"domain" => %{"name" => "foo"}})
             |> render_submit() =~ "must be a valid domain"

      refute view
             |> form("#create-domain", %{"domain" => %{"name" => "foo.com"}})
             |> render_submit() =~ "must be a valid domain"
    end
  end
end
