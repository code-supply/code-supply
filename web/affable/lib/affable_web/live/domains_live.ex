defmodule AffableWeb.DomainsLive do
  use AffableWeb, :live_view
  require Logger

  alias Affable.Accounts
  alias Affable.Domains
  alias Affable.Domains.Domain
  alias Affable.Sites
  alias Affable.K8sFactories

  import Ecto.Query, only: [from: 2]

  @impl true
  def mount(_params, %{"user_token" => token}, socket) do
    user =
      Accounts.get_user_by_session_token(token)
      |> Affable.Repo.preload(
        domains: from(d in Domain, order_by: [desc: d.id], preload: [:site])
      )

    if connected?(socket) do
    end

    {:ok,
     assign(socket, %{
       user: user,
       domains: user.domains,
       changeset: %Domain{} |> Domains.change_domain(%{}),
       sites: user.sites
     })}
  end

  @impl true
  def handle_event("validate", %{"domain" => params}, socket) do
    changeset =
      %Domain{}
      |> Domains.change_domain(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event(
        "create",
        %{"domain" => %{"site_id" => site_id, "name" => new_name}},
        %{assigns: %{user: user}} = socket
      ) do
    site = Sites.get_site!(user, site_id)

    case Domains.create_domain(site, %{name: new_name}) do
      {:ok, new_domain} ->
        case site
             |> K8sFactories.affiliate_site(new_name)
             |> k8s().patch() do
          {:ok, _} ->
            Logger.info("Successfully added #{new_name} to site #{site_id}")

          {:error, msg} ->
            Logger.error("Failed to add #{new_name} to site #{site_id}: #{msg}")
        end

        {:noreply, update(socket, :domains, &Domains.list_insert(&1, new_domain))}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event(
        "delete",
        %{"id" => id},
        %{assigns: %{user: user}} = socket
      ) do
    domain = Domains.delete_domain!(user, id)

    Sites.get_site!(user, domain.site_id)
    |> K8sFactories.affiliate_site()
    |> k8s().patch()

    {:noreply,
     update(socket, :domains, fn domains ->
       Enum.reduce(domains, [], fn domain, acc ->
         if "#{domain.id}" == id do
           acc
         else
           acc ++ [domain]
         end
       end)
     end)}
  end

  defp k8s() do
    Application.get_env(:affable, :k8s)
  end
end
