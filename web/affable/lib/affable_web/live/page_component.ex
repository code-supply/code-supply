defmodule AffableWeb.PageComponent do
  use AffableWeb, :live_component

  alias Affable.Sites

  import AffableWeb.EditorHelpers
  import Affable.Assets, only: [to_imgproxy_url: 1]

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

  def handle_event(
        "new-item",
        %{},
        %{assigns: %{site: site, user: user, page: page}} = socket
      ) do
    {:ok, changed_site, appended_item} =
      site
      |> Sites.append_item(page, user)

    send(self(), {:updated_page, changed_site.pages |> Enum.find(fn p -> p.id == page.id end)})

    {:noreply, push_event(socket, "scroll", %{id: "item-#{appended_item.id}"})}
  end

  def handle_event(
        "demote",
        %{"id" => item_id},
        %{assigns: %{site: site, user: user, page: page}} = socket
      ) do
    site = Sites.get_site!(user, site.id)

    {:ok, changed_site} = Sites.demote_item(site, page, item_id)
    send(self(), {:updated_page, changed_site.pages |> Enum.find(fn p -> p.id == page.id end)})

    {:noreply, socket}
  end

  def handle_event(
        "promote",
        %{"id" => item_id},
        %{assigns: %{site: site, user: user, page: page}} = socket
      ) do
    site = Sites.get_site!(user, site.id)

    {:ok, changed_site} = Sites.promote_item(site, page, item_id)
    send(self(), {:updated_page, changed_site.pages |> Enum.find(fn p -> p.id == page.id end)})

    {:noreply, socket}
  end

  def handle_event(
        "delete-item",
        %{"id" => item_id},
        %{assigns: %{site: site, user: user, page: page}} = socket
      ) do
    {:ok, site} =
      Sites.get_site!(user, site.id)
      |> Sites.delete_item(page, item_id)

    send(self(), {:updated_site, site})

    {:noreply, socket}
  end
end
