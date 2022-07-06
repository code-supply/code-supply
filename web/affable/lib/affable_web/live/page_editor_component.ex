defmodule AffableWeb.PageEditorComponent do
  use AffableWeb, :live_component

  alias Affable.Sites
  alias Affable.Sites.Page

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(
       site: assigns.site,
       user: assigns.user,
       asset_pairs: assigns.asset_pairs,
       changeset: assigns.changeset,
       page: assigns.page
     )
     |> allow_upload(
       :content,
       progress: &handle_progress/3,
       accept: ~w(.html),
       max_entries: 1
     )}
  end

  def handle_event("save", %{"page" => params}, %{assigns: %{user: user, page: page}} = socket) do
    params =
      case consume_uploaded_entries(socket, :content, fn %{path: path}, _entry ->
             File.read(path)
           end) do
        [raw] ->
          Map.put(params, "raw", raw)

        [] ->
          params
      end

    case Sites.update_page(page, params, user) do
      {:ok, page} ->
        send(self(), {:updated_page, page})

      {:error, changeset} ->
        send(self(), {:erroneous_page, changeset})
    end

    {:noreply, socket}
  end

  def handle_event("validate", %{"page" => params}, %{assigns: %{page: page}} = socket) do
    {:noreply,
     assign(socket, changeset: Page.changeset(page, params) |> Map.put(:action, :validate))}
  end

  def handle_event("delete", %{"id" => id}, %{assigns: %{user: user}} = socket) do
    {:ok, page} = Sites.delete_page(id, user)
    send(self(), {:deleted_page, page})
    {:noreply, socket}
  end

  defp handle_progress(:content, entry, socket) do
    if entry.done? do
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end
end
