defmodule AffableWeb.SitesLive do
  use AffableWeb, :old_live_view

  require Logger

  alias Affable.Accounts
  alias Affable.Sites
  alias Affable.Sites.Site

  import Affable.Sites, only: [canonical_url: 2]

  @impl true
  def mount(_params, %{"user_token" => token}, socket) do
    user =
      Accounts.get_user_by_session_token(token)
      |> Accounts.preload_for_sites()

    {:ok,
     assign(
       socket,
       user: user,
       sites: user.sites,
       changeset: %Site{} |> Site.changeset(%{})
     )}
  end

  @impl true
  def handle_info(
        %Site{} = received_site,
        %{assigns: %{sites: sites}} = socket
      ) do
    Logger.info(
      "Received site #{received_site.internal_name} made available at #{received_site.made_available_at}"
    )

    updated_sites =
      sites
      |> Enum.map(fn site ->
        if site.id == received_site.id do
          received_site
        else
          site
        end
      end)

    {:noreply, assign(socket, sites: updated_sites)}
  end

  @impl true
  def handle_event(
        "create",
        %{"site" => attrs},
        %{assigns: %{user: user}} = socket
      ) do
    case Sites.create_bare_site(user, attrs) do
      {:ok, site} ->
        {:noreply, update(socket, :sites, fn sites -> [site | sites] end)}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def handle_event(
        "delete",
        %{"id" => site_id},
        %{assigns: %{user: user}} = socket
      ) do
    site = Sites.get_site!(user, site_id)
    Sites.delete_site(site)

    {:noreply,
     update(socket, :sites, fn sites ->
       Enum.reject(sites, fn %Site{id: id} -> "#{id}" == site_id end)
     end)}
  end
end
