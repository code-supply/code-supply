defmodule AffableWeb.SitesLive do
  use AffableWeb, :live_view

  alias Affable.Accounts
  alias Affable.Accounts.User
  import Affable.Sites, only: [canonical_url: 1, status: 1]

  @impl true
  def mount(_params, %{"user_token" => token}, socket) do
    case Accounts.get_user_by_session_token(token) do
      %User{} = user ->
        user = user |> Affable.Repo.preload(sites: :domains)

        if connected?(socket) do
          for site <- user.sites do
            Phoenix.PubSub.subscribe(:affable, site.internal_name)
          end
        end

        {:ok, assign(socket, sites: user.sites, user_confirmed_at: user.confirmed_at)}
    end
  end

  @impl true
  def handle_info(raw_site, %{assigns: %{sites: sites}} = socket) do
    updated_sites =
      sites
      |> Enum.map(fn site ->
        if site.id == raw_site.id do
          %{site | made_available_at: raw_site.made_available_at}
        else
          site
        end
      end)

    {:noreply, assign(socket, sites: updated_sites)}
  end
end
