defmodule AffableWeb.AffiliateSitesLive do
  use AffableWeb, :live_view

  alias Affable.Accounts
  alias Affable.Accounts.User
  alias Affable.Sites
  alias Affable.Sites.Site

  def mount(%{"id" => id}, %{"user_token" => token}, socket) do
    case Accounts.get_user_by_session_token(token) do
      nil ->
        redirect_to_login(socket)

      %User{} = user ->
        {:ok, retrieve_state(user, socket, id)}
    end
  end

  def mount(_params, _logged_out_session, socket) do
    redirect_to_login(socket)
  end

  def handle_event(
        "new-attribute-definition",
        %{},
        %{assigns: %{changeset: %{data: site}, user: user}} = socket
      ) do
    {:ok, site} = Sites.add_attribute_definition(user, site)

    complete_update(socket, site)
  end

  def handle_event(
        "delete-attribute-definition",
        %{"id" => definition_id},
        %{assigns: %{site_id: id, user: user}} = socket
      ) do
    {:ok, _} = Sites.delete_attribute_definition(user, definition_id)
    complete_update(socket, Sites.get_site!(user, id))
  end

  def handle_event("new-item", %{}, %{assigns: %{user: user, changeset: %{data: site}}} = socket) do
    {:ok, new_item} = Sites.prepend_item(user, site)

    repositioned =
      site.items
      |> Enum.map(fn item ->
        %{item | position: item.position + 1}
      end)

    complete_update(socket, %{site | items: [new_item | repositioned]})
  end

  def handle_event("save", %{"site" => attrs}, %{assigns: %{site_id: id, user: user}} = socket) do
    site = Sites.get_site!(user, id)

    case Sites.update_site(site, attrs) do
      {:ok, site} ->
        complete_update(socket, site)

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset, saved_state: :error)}
    end
  end

  def handle_event(
        "delete-item",
        %{"id" => item_id},
        %{assigns: %{site_id: id, user: user}} = socket
      ) do
    site = Sites.get_site!(user, id)
    {:ok, site} = Sites.delete_item(site, item_id)
    complete_update(socket, site)
  end

  def handle_event("promote", %{"id" => item_id}, %{assigns: %{site_id: id, user: user}} = socket) do
    site = Sites.get_site!(user, id)

    {:ok, site} = Sites.promote_item(user, site, item_id)
    complete_update(socket, site)
  end

  def handle_event("demote", %{"id" => item_id}, %{assigns: %{site_id: id, user: user}} = socket) do
    site = Sites.get_site!(user, id)

    {:ok, site} = Sites.demote_item(user, site, item_id)
    complete_update(socket, site)
  end

  def handle_info(:clear_save, socket) do
    {:noreply, assign(socket, saved_state: :clear)}
  end

  defp redirect_to_login(socket) do
    {:ok, redirect(socket, to: "/users/log_in")}
  end

  defp retrieve_state(user, socket, id) do
    site = Sites.get_site!(user, id)

    assign(socket,
      user: user,
      site_id: id,
      changeset: Site.changeset(site, %{}),
      saved_state: :neutral
    )
  end

  defp complete_update(socket, site) do
    site
    |> broadcast()
    |> reset_changeset(socket)
  end

  defp broadcast(site) do
    :ok = broadcaster().broadcast(Sites.Raw.raw(site))
    site
  end

  defp reset_changeset(site, socket) do
    Process.send_after(self(), :clear_save, 2000)
    {:noreply, assign(socket, changeset: Site.changeset(site, %{}), saved_state: :saved)}
  end

  defp broadcaster() do
    Application.get_env(:affable, :broadcaster)
  end
end
