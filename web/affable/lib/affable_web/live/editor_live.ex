defmodule AffableWeb.EditorLive do
  require Logger

  use AffableWeb, :live_view

  alias Affable.Accounts
  alias Affable.Sites
  alias Affable.Sites.{Page, Site}

  import AffableWeb.EditorHelpers

  def mount(%{"id" => id}, %{"user_token" => token}, socket) do
    user = Accounts.get_user_by_session_token(token)
    {:ok, retrieve_state(user, socket, id)}
  end

  def handle_params(
        %{"id" => _id, "page_id" => page_id},
        _path,
        %{assigns: %{pages: pages, preview_url: preview_url}} = socket
      ) do
    {page, changeset} =
      Enum.find(pages, fn {p, _cs} ->
        "#{page_id}" == "#{p.id}"
      end)

    {:noreply,
     socket
     |> assign_preview_url(preview_url, page.path)
     |> assign(
       page: page,
       page_changeset: changeset
     )}
  end

  def handle_params(
        %{"id" => _id},
        _path,
        %{assigns: %{preview_url: preview_url}} = socket
      ) do
    uri = URI.parse(preview_url)

    {:noreply,
     assign(
       socket,
       page: nil,
       preview_url: uri |> URI.merge("/preview") |> URI.to_string()
     )}
  end

  def handle_info(
        {:updated_page, %Page{id: id} = updated_page},
        %{assigns: %{preview_url: preview_url, changeset: %{data: site}}} = socket
      ) do
    %{
      site
      | pages:
          Enum.map(site.pages, fn
            %Page{id: ^id} -> updated_page
            page -> page
          end)
    }
    |> reset_site(
      socket
      |> assign_preview_url(preview_url, updated_page.path)
      |> assign(page: updated_page, page_changeset: Page.changeset(updated_page, %{}))
    )
  end

  def handle_info(
        {:deleted_page, %Page{id: id}},
        %{assigns: %{changeset: %{data: site}}} = socket
      ) do
    %{
      site
      | pages: Enum.filter(site.pages, &(&1.id != id))
    }
    |> reset_site(
      socket
      |> assign(page: nil, page_changeset: nil)
      |> push_patch(to: Routes.editor_path(socket, :edit, site.id))
    )
  end

  def handle_info(
        {:erroneous_page, %{data: %{id: id}} = erroneous_changeset},
        %{assigns: %{pages: pages}} = socket
      ) do
    {:noreply,
     assign(
       socket,
       pages:
         Enum.map(pages, fn
           {%Page{id: ^id} = page, _} -> {page, erroneous_changeset}
           pair -> pair
         end),
       page_changeset: erroneous_changeset
     )}
  end

  def handle_info({:updated_site, site}, socket) do
    reset_site(site, socket)
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
        "new-page",
        %{},
        %{assigns: %{changeset: %{data: site}, user: user}} = socket
      ) do
    {:ok, page} = site |> Sites.add_page(user)

    %{site | pages: site.pages ++ [page]}
    |> Sites.with_pages()
    |> reset_site(push_patch(socket, to: Routes.editor_path(socket, :edit, site.id, page.id)))
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

  def handle_event(
        "save",
        %{"site" => attrs},
        %{assigns: %{site_id: id, user: user}} = socket
      ) do
    Sites.get_site!(user, id)
    |> Sites.update_site(attrs)
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

  defp retrieve_state(user, socket, id) do
    site = Sites.get_site!(user, id)

    assign(socket,
      checked: true,
      user: user,
      site_id: id,
      pages: Enum.map(site.pages, fn page -> {page, Page.changeset(page, %{})} end),
      asset_pairs: Enum.map(site.assets, &{&1.name, &1.id}),
      changeset: Site.changeset(site, %{}),
      published: Sites.is_published?(site),
      preview_url: Sites.preview_url(site),
      canonical_url: Sites.canonical_url(site)
    )
  end

  defp reset_site(%Site{} = site, socket) do
    {:noreply,
     assign(socket,
       changeset: Site.changeset(site, %{}),
       published: Sites.is_published?(site),
       pages:
         for page <- site.pages do
           {page, Page.changeset(page, %{})}
         end
     )}
  end

  defp reset_site({:ok, site}, socket) do
    reset_site(site, socket)
  end

  defp reset_site({:error, changeset}, socket) do
    {:noreply, assign(socket, changeset: changeset)}
  end

  defp assign_preview_url(socket, preview_url, page_path) do
    uri = URI.parse(preview_url)

    preview_path =
      case page_path do
        "/" ->
          "/preview"

        p ->
          "/preview#{p}"
      end

    assign(socket, preview_url: uri |> URI.merge(preview_path) |> URI.to_string())
  end
end
