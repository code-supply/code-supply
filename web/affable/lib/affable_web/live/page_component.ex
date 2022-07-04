defmodule AffableWeb.PageComponent do
  use AffableWeb, :live_component

  alias Affable.Sites

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
