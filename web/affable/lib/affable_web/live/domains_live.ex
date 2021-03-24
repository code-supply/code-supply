defmodule AffableWeb.DomainsLive do
  use AffableWeb, :live_view

  alias Affable.Accounts
  alias Affable.Domains
  alias Affable.Domains.Domain
  alias Affable.Sites

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
        %{"domain" => %{"site_id" => site_id, "name" => name}},
        %{assigns: %{user: user}} = socket
      ) do
    site = Sites.get_site!(user, site_id)

    case Domains.create_domain(site, %{name: name}) do
      {:ok, domain} ->
        {:noreply, update(socket, :domains, fn domains -> [domain | domains] end)}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end