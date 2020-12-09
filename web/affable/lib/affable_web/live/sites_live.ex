defmodule AffableWeb.SitesLive do
  use AffableWeb, :live_view

  alias Affable.Accounts

  import Affable.Sites, only: [canonical_url: 1, status: 1]

  @impl true
  def mount(_params, %{"user_token" => token}, socket) do
    user =
      Accounts.get_user_by_session_token(token)
      |> Affable.Repo.preload(sites: :domains)

    if connected?(socket) do
      for site <- user.sites do
        Phoenix.PubSub.subscribe(:affable, site.internal_name)
      end
    end

    {:ok, assign(socket, sites: user.sites)}
  end

  @impl true
  def handle_info(%{preview: preview}, %{assigns: %{sites: sites}} = socket) do
    updated_sites =
      sites
      |> Enum.map(fn site ->
        if site.id == preview["id"] do
          %{site | made_available_at: preview["made_available_at"]}
        else
          site
        end
      end)

    {:noreply, assign(socket, sites: updated_sites)}
  end
end
