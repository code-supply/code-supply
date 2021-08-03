defmodule AffableWeb.PageComponent do
  use AffableWeb, :live_component

  alias Affable.Sites

  import AffableWeb.EditorHelpers

  def update(assigns, socket) do
    {:ok,
     assign(socket,
       user: assigns.user,
       asset_pairs: assigns.asset_pairs,
       changeset: assigns.changeset,
       page: assigns.page
     )}
  end

  def handle_event("save", %{"page" => params}, %{assigns: %{page: page}} = socket) do
    case Sites.update_page(page, params) do
      {:ok, page} ->
        send(self(), {:updated_page, page})

      {:error, changeset} ->
        send(self(), {:erroneous_page, changeset})
    end

    {:noreply, socket}
  end
end
