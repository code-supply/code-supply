defmodule AffableWeb.AccountLive do
  use AffableWeb, :live_view

  alias Affable.Accounts
  alias Affable.Accounts.User

  def mount(_params, %{"user_token" => token}, socket) do
    case Accounts.get_user_by_session_token(token) do
      nil ->
        redirect_to_login(socket)

      %User{} = user ->
        {:ok, socket}
    end
  end

  def mount(_params, _logged_out_session, socket) do
    redirect_to_login(socket)
  end

  defp redirect_to_login(socket) do
    {:ok, redirect(socket, to: "/users/log_in")}
  end
end
