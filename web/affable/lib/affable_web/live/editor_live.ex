defmodule AffableWeb.EditorLive do
  require Logger

  use AffableWeb, :live_view

  alias Affable.Accounts
  alias Affable.Accounts.User
  alias Affable.Sites
  alias Affable.Sites.Site

  import Affable.Sites, only: [broadcast: 1]

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
        "publish",
        _params,
        %{assigns: %{user: user, site_id: site_id}} = socket
      ) do
    site = Sites.get_site!(user, site_id)
    {:ok, site} = Sites.publish(site)

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
    site
    |> Sites.append_item(user)
    |> reset_site(socket)
  end

  def handle_event(
        "save",
        %{"site" => attrs},
        %{assigns: %{site_id: id, user: user}} = socket
      ) do
    Sites.get_site!(user, id)
    |> Sites.update_site(attrs)
    |> reset_site(socket)
  end

  def handle_event(
        "delete-item",
        %{"id" => item_id},
        %{assigns: %{site_id: id, user: user}} = socket
      ) do
    Sites.get_site!(user, id)
    |> Sites.delete_item(item_id)
    |> reset_site(socket)
  end

  def handle_event("promote", %{"id" => item_id}, %{assigns: %{site_id: id, user: user}} = socket) do
    site = Sites.get_site!(user, id)

    Sites.promote_item(user, site, item_id)
    |> reset_site(socket)
  end

  def handle_event("demote", %{"id" => item_id}, %{assigns: %{site_id: id, user: user}} = socket) do
    site = Sites.get_site!(user, id)

    Sites.demote_item(user, site, item_id)
    |> reset_site(socket)
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
      saved_state: :neutral,
      published: Sites.is_published?(site),
      preview_url: "#{Sites.canonical_url(site)}preview"
    )
  end

  defp complete_update(socket, site) do
    site
    |> broadcast()
    |> reset_site(socket)
  end

  defp reset_site(%Site{} = site, socket) do
    Process.send_after(self(), :clear_save, 2000)

    {:noreply,
     assign(socket,
       changeset: Site.changeset(site, %{}),
       saved_state: :saved,
       published: Sites.is_published?(site)
     )}
  end

  defp reset_site({:ok, site}, socket) do
    reset_site(site, socket)
  end

  defp reset_site({:error, changeset}, socket) do
    Logger.error("CHANGESET: #{inspect(changeset)}\n\nSOCKET: #{inspect(socket)}")
    {:noreply, assign(socket, changeset: changeset, saved_state: :error)}
  end
end
