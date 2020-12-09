defmodule AffableWeb.AssetsLive do
  use AffableWeb, :live_view

  alias Affable.Accounts
  alias Affable.Accounts.User

  @impl true
  def mount(_params, %{"user_token" => token}, socket) do
    case Accounts.get_user_by_session_token(token) do
      %User{} = user ->
        if connected?(socket) do
        end

        {:ok, assign(socket, user_confirmed_at: user.confirmed_at)}
    end
  end
end
