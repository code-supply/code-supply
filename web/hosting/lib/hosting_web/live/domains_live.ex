defmodule HostingWeb.DomainsLive do
  use HostingWeb, :old_live_view
  require Logger

  alias Hosting.Accounts
  alias Hosting.Domains
  alias Hosting.Domains.Domain
  alias Hosting.Sites

  import Ecto.Query, only: [from: 2]

  @impl true
  def mount(_params, %{"user_token" => token}, socket) do
    user =
      Accounts.get_user_by_session_token(token)
      |> Hosting.Repo.preload(
        domains: from(d in Domain, order_by: [desc: d.id], preload: [:site])
      )

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
        case k8s().deploy(Domains.k8s_certificate(site.internal_name, new_domain.name)) do
          {:ok, _} ->
            Logger.info(
              "Successfully created certificate for #{site.internal_name} / #{new_domain.name}"
            )

          {:error, msg} ->
            Logger.error(
              "Failed to create certificate for #{site.internal_name} / #{new_domain.name}: #{msg}"
            )
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

    k8s().undeploy(Domains.k8s_certificate(domain.site.internal_name, domain.name))

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

  defp k8s do
    Application.get_env(:hosting, :k8s)
  end
end
