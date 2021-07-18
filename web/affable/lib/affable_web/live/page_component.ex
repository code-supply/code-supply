defmodule AffableWeb.PageComponent do
  use AffableWeb, :live_component

  alias Affable.Sites
  alias Affable.Sites.Page

  import AffableWeb.EditorHelpers

  def update(assigns, socket) do
    {:ok,
     assign(socket,
       asset_pairs: assigns.asset_pairs,
       changeset: Page.changeset(assigns.page, %{}),
       page: assigns.page
     )}
  end

  def handle_event("save", %{"page" => params}, %{assigns: %{page: page}} = socket) do
    {:ok, page} = Sites.update_page(page, params)
    send(self(), {:updated_page, page})
    {:noreply, socket}
  end
end
