defmodule AffableWeb.DashboardLive do
  use AffableWeb, :live_view

  alias Affable.Accounts
  alias Affable.Accounts.User
  import Affable.Sites, only: [status: 1]

  @impl true
  def mount(_params, %{"user_token" => token}, socket) do
    case Accounts.get_user_by_session_token(token) do
      %User{} = user ->
        {:ok, assign(socket, user: user |> Affable.Repo.preload(sites: :domains))}
    end
  end
end
