defmodule AffableWeb.SitesLive do
  use AffableWeb, :live_view

  require Logger

  alias Affable.Accounts
  alias Affable.Sites
  alias Affable.Sites.Site
  alias Affable.Domains.Domain
  alias Affable.K8sFactories

  import Affable.Sites, only: [canonical_url: 1, status: 1]

  @impl true
  def mount(_params, %{"user_token" => token}, socket) do
    user =
      Accounts.get_user_by_session_token(token)
      |> Accounts.preload_for_sites()

    if connected?(socket) do
      for site <- user.sites do
        Phoenix.PubSub.subscribe(:affable, site.internal_name)
      end
    end

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
      "Received site #{received_site.internal_name} made available at #{
        received_site.made_available_at
      }"
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
    {:ok,
     %Site{
       internal_name: internal_name,
       domains: [%Domain{name: domain_name}]
     } = site} = Sites.create_bare_site(user, attrs)

    case k8s().deploy(K8sFactories.affiliate_site(internal_name, [domain_name])) do
      {:ok, _} ->
        Logger.info("Deployed site #{internal_name} for the first time")

      {:error, msg} ->
        Logger.error("Failed to deploy #{internal_name}: #{msg}")
    end

    Phoenix.PubSub.subscribe(:affable, internal_name)

    {:noreply, update(socket, :sites, fn sites -> [site | sites] end)}
  end

  defp k8s() do
    Application.get_env(:affable, :k8s)
  end
end
