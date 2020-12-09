defmodule AffableWeb.EditorLive do
  require Logger

  use AffableWeb, :live_view

  alias Affable.Accounts
  alias Affable.Sites
  alias Affable.Sites.Site

  def mount(%{"id" => id}, %{"user_token" => token}, socket) do
    user = Accounts.get_user_by_session_token(token)
    {:ok, retrieve_state(user, socket, id)}
  end

  def handle_event(
        "new-attribute-definition",
        %{},
        %{assigns: %{changeset: %{data: site}, user: user}} = socket
      ) do
    site
    |> Sites.add_attribute_definition(user)
    |> reset_site(socket)
  end

  def handle_event(
        "publish",
        _params,
        %{assigns: %{user: user, site_id: site_id}} = socket
      ) do
    Sites.get_site!(user, site_id)
    |> Sites.publish()
    |> reset_site(socket)
  end

  def handle_event(
        "delete-attribute-definition",
        %{"id" => definition_id},
        %{assigns: %{site_id: site_id, user: user}} = socket
      ) do
    Sites.delete_attribute_definition(site_id, definition_id, user)
    |> reset_site(socket)
  end

  def handle_event("new-item", %{}, %{assigns: %{user: user, changeset: %{data: site}}} = socket) do
    {_, %{assigns: %{changeset: %{data: changed_site}}} = socket} =
      site
      |> Sites.append_item(user)
      |> reset_site(socket)

    {:noreply, push_event(socket, "scroll", %{id: "item-#{List.last(changed_site.items).id}"})}
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

  defp redirect_to_login(socket) do
    {:ok, redirect(socket, to: "/users/log_in")}
  end

  defp retrieve_state(user, socket, id) do
    site = Sites.get_site!(user, id)

    assign(socket,
      user: user,
      site_id: id,
      changeset: Site.changeset(site, %{}),
      published: Sites.is_published?(site),
      preview_url: "#{Sites.canonical_url(site)}preview"
    )
  end

  defp reset_site(%Site{} = site, socket) do
    {:noreply,
     assign(socket,
       changeset: Site.changeset(site, %{}),
       published: Sites.is_published?(site)
     )}
  end

  defp reset_site({:ok, site}, socket) do
    reset_site(site, socket)
  end

  defp reset_site({:error, changeset}, socket) do
    {:noreply, assign(socket, changeset: changeset)}
  end
end
