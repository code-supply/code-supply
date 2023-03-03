defmodule AffableWeb.UserSettingsControllerTest do
  use AffableWeb.ConnCase, async: true

  alias Affable.Accounts
  alias Affable.Sites

  import Affable.AccountsFixtures

  setup :register_and_log_in_user

  describe "GET /users/settings" do
    test "renders settings page", %{conn: conn} do
      conn = get(conn, test_path(conn, :edit))
      response = html_response(conn, 200)
      assert response =~ "<h1>Settings</h1>"
    end

    test "redirects if user is not logged in" do
      conn = build_conn()
      conn = get(conn, test_path(conn, :edit))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    end
  end

  describe "PUT /users/settings/update_password" do
    test "updates the user password and resets tokens", %{conn: conn, user: user} do
      new_password_conn =
        put(conn, test_path(conn, :update_password), %{
          "current_password" => valid_user_password(),
          "user" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(new_password_conn) == Routes.user_settings_path(conn, :edit)
      assert get_session(new_password_conn, :user_token) != get_session(conn, :user_token)

      assert Phoenix.Flash.get(new_password_conn.assigns.flash, :info) =~
               "Password updated successfully"

      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "does not update password on invalid data", %{conn: conn} do
      old_password_conn =
        put(conn, test_path(conn, :update_password), %{
          "current_password" => "invalid",
          "user" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      response = html_response(old_password_conn, 200)
      assert response =~ "<h1>Settings</h1>"
      assert response =~ "should be at least 12 character(s)"
      assert response =~ "does not match password"
      assert response =~ "is not valid"

      assert get_session(old_password_conn, :user_token) == get_session(conn, :user_token)
    end
  end

  describe "PUT /users/settings/update_email" do
    @tag :capture_log
    test "updates the user email", %{conn: conn, user: user} do
      conn =
        put(conn, test_path(conn, :update_email), %{
          "current_password" => valid_user_password(),
          "user" => %{"email" => unique_user_email()}
        })

      assert redirected_to(conn) == Routes.user_settings_path(conn, :edit)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "A link to confirm your e-mail"
      assert Accounts.get_user_by_email(user.email)
    end

    test "does not update email on invalid data", %{conn: conn} do
      conn =
        put(conn, test_path(conn, :update_email), %{
          "current_password" => "invalid",
          "user" => %{"email" => "with spaces"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Settings</h1>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "is not valid"
    end
  end

  describe "GET /users/settings/confirm_email/:token" do
    setup %{user: user} do
      email = unique_user_email()

      token =
        extract_user_token(fn url ->
          Accounts.deliver_update_email_instructions(%{user | email: email}, user.email, url)
        end)

      %{token: token, email: email}
    end

    test "updates the user email once", %{conn: conn, user: user, token: token, email: email} do
      conn = get(conn, test_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.user_settings_path(conn, :edit)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "E-mail changed successfully"
      refute Accounts.get_user_by_email(user.email)
      assert Accounts.get_user_by_email(email)

      conn = get(conn, test_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.user_settings_path(conn, :edit)

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Email change link is invalid or it has expired"
    end

    test "does not update email with invalid token", %{conn: conn, user: user} do
      conn = get(conn, test_path(conn, :confirm_email, "oops"))
      assert redirected_to(conn) == Routes.user_settings_path(conn, :edit)

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Email change link is invalid or it has expired"

      assert Accounts.get_user_by_email(user.email)
    end

    test "redirects if user is not logged in", %{token: token} do
      conn = build_conn()
      conn = get(conn, test_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
    end
  end

  describe "DELETE /users/settings/delete_account" do
    test "deletes the account and redirects to home page", %{conn: conn, user: user} do
      conn = delete(conn, test_path(conn, :delete_account))

      assert redirected_to(conn) == "/"

      assert_raise(Ecto.NoResultsError, fn ->
        Accounts.get_user!(user.id)
      end)
    end

    test "doesn't delete shared sites", %{
      conn: conn,
      user: %Accounts.User{sites: [site]} = user
    } do
      colleague = user_fixture()

      %Sites.SiteMember{user: colleague, site: site}
      |> Affable.Repo.insert()

      conn = delete(conn, test_path(conn, :delete_account))

      assert redirected_to(conn) == "/"

      assert_raise(Ecto.NoResultsError, fn ->
        Accounts.get_user!(user.id)
      end)

      assert Sites.get_site!(colleague, site.id)
    end
  end

  defp test_path(conn, action) do
    conn
    |> Routes.user_settings_path(action)
    |> control_plane_path()
  end

  defp test_path(conn, action, token) do
    conn
    |> Routes.user_settings_path(action, token)
    |> control_plane_path()
  end
end
