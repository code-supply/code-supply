defmodule AffableWeb.PageComponent do
  use AffableWeb, :live_component

  alias Affable.Sites

  import AffableWeb.EditorHelpers

  def update(assigns, socket) do
    {:ok,
     assign(socket,
       site: assigns.site,
       user: assigns.user,
       asset_pairs: assigns.asset_pairs,
       changeset: assigns.changeset,
       page: assigns.page
     )}
  end

  def handle_event(
        "new-section",
        %{},
        %{assigns: %{user: user, page: page}} = socket
      ) do
    case Sites.add_page_section(page, user) do
      {:ok, page} ->
        send(self(), {:updated_page, page})

      {:error, changeset} ->
        send(self(), {:erroneous_page, changeset})
    end

    {:noreply, socket}
  end

  def handle_event(
        "delete-section",
        %{"id" => id},
        %{assigns: %{user: user}} = socket
      ) do
    {:ok, section} = Sites.delete_page_section(id, user)
    send(self(), {:deleted_section, section})
    {:noreply, socket}
  end

  def handle_event("save", %{"page" => params}, %{assigns: %{user: user, page: page}} = socket) do
    case Sites.update_page(page, params, user) do
      {:ok, page} ->
        send(self(), {:updated_page, page})

      {:error, changeset} ->
        send(self(), {:erroneous_page, changeset})
    end

    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, %{assigns: %{user: user}} = socket) do
    {:ok, page} = Sites.delete_page(id, user)
    send(self(), {:deleted_page, page})
    {:noreply, socket}
  end
end
