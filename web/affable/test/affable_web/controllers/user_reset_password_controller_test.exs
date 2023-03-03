defmodule AffableWeb.UserResetPasswordControllerTest do
  use AffableWeb.ConnCase, async: true
  use Bamboo.Test

  alias Affable.Accounts
  alias Affable.Repo
  import Affable.AccountsFixtures

  setup do
    %{user: unconfirmed_user_fixture()}
  end

  describe "GET /users/reset_password" do
    test "renders the reset password page", %{conn: conn} do
      conn = get(conn, test_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Forgot your password?</h1>"
    end
  end

  describe "POST /users/reset_password" do
    setup do
      %{expected_subject: "Affable password reset request"}
    end

    test "sends a new reset password token", %{
      conn: conn,
      user: user,
      expected_subject: expected_subject
    } do
      conn =
        post(conn, test_path(conn, :create), %{
          "user" => %{"email" => user.email}
        })

      assert redirected_to(conn) == "/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your e-mail is in our system"
      assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context == "reset_password"

      assert_email_delivered_with(
        to: [nil: user.email],
        subject: expected_subject
      )
    end

    test "does not send reset password token if email is invalid", %{
      conn: conn,
      expected_subject: expected_subject
    } do
      conn =
        post(conn, test_path(conn, :create), %{
          "user" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your e-mail is in our system"
      assert Repo.all(Accounts.UserToken) == []

      refute_email_delivered_with(subject: expected_subject)
    end
  end

  describe "GET /users/reset_password/:token" do
    setup %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      %{token: token}
    end

    test "renders reset password", %{conn: conn, token: token} do
      conn = get(conn, test_path(conn, :edit, token))
      assert html_response(conn, 200) =~ "<h1>Reset password</h1>"
    end

    test "does not render reset password with invalid token", %{conn: conn} do
      conn = get(conn, test_path(conn, :edit, "oops"))
      assert redirected_to(conn) == "/"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Reset password link is invalid or it has expired"
    end
  end

  describe "PUT /users/reset_password/:token" do
    setup %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      %{token: token}
    end

    test "resets password once", %{conn: conn, user: user, token: token} do
      conn =
        put(conn, test_path(conn, :update, token), %{
          "user" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
      refute get_session(conn, :user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Password reset successfully"
      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "does not reset password on invalid data", %{conn: conn, token: token} do
      conn =
        put(conn, test_path(conn, :update, token), %{
          "user" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Reset password</h1>"
      assert response =~ "should be at least 12 character(s)"
      assert response =~ "does not match password"
    end

    test "does not reset password with invalid token", %{conn: conn} do
      conn = put(conn, test_path(conn, :update, "oops"))
      assert redirected_to(conn) == "/"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Reset password link is invalid or it has expired"
    end
  end

  defp test_path(conn, action) do
    conn
    |> Routes.user_reset_password_path(action)
    |> control_plane_path()
  end

  defp test_path(conn, action, token) do
    conn
    |> Routes.user_reset_password_path(action, token)
    |> control_plane_path()
  end
end
