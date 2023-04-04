defmodule HostingWeb.EditorLive do
  require Logger

  use HostingWeb, :old_live_view

  alias Hosting.Accounts
  alias Hosting.Sites
  alias Hosting.Sites.{Page, Site}

  def mount(%{"id" => id}, %{"user_token" => token}, socket) do
    user = Accounts.get_user_by_session_token(token)
    {:ok, retrieve_state(user, socket, id)}
  end

  def handle_params(
        %{"id" => id, "page_id" => page_id},
        _uri,
        %{assigns: %{pages: pages, preview_url: preview_url}} = socket
      ) do
    case Enum.find(pages, fn {p, _cs} ->
           "#{page_id}" == "#{p.id}"
         end) do
      nil ->
        {:noreply, push_redirect(socket, to: Routes.editor_path(socket, :edit, id))}

      {page, changeset} ->
        {:noreply,
         socket
         |> assign_preview_url(preview_url, page.path)
         |> assign(page: page, page_changeset: changeset)}
    end
  end

  def handle_params(
        %{"id" => _id},
        _uri,
        %{assigns: %{preview_url: preview_url, pages: pages}} = socket
      ) do
    {:noreply,
     socket
     |> assign(page: nil)
     |> assign_preview_url(preview_url, Sites.default_path(for {p, _} <- pages, do: p.path))}
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
      |> assign_page(updated_page)
    )
  end

  def handle_info(
        {:deleted_page, %Page{id: id}},
        %{assigns: %{changeset: %{data: site}}} = socket
      ) do
    %Site{site | pages: Enum.filter(site.pages, &(&1.id != id))}
    |> reset_site(
      socket
      |> assign_page(nil)
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
        "new-page",
        %{},
        %{assigns: %{changeset: %{data: site}, user: user}} = socket
      ) do
    {:ok, page} = site |> Sites.add_page(user)

    %{site | pages: site.pages ++ [page]}
    |> Sites.with_pages()
    |> reset_site(push_patch(socket, to: Routes.editor_path(socket, :edit, site.id, page.id)))
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "save",
        %{"site" => attrs},
        %{assigns: %{site_id: id, user: user}} = socket
      ) do
    site = Sites.get_site!(user, id)

    attrs =
      case consume_uploaded_entries(socket, :stylesheet, fn %{path: path}, _entry ->
             File.read(path)
           end) do
        [raw] ->
          Map.put(attrs, "stylesheet", raw)

        [] ->
          attrs
      end

    site
    |> Sites.update_site(attrs)
    |> reset_site(socket)
  end

  defp retrieve_state(user, socket, id) do
    site = Sites.get_site!(user, id)
    canonical_url = Sites.canonical_url(site, Application.get_env(:hosting, :sites_port))

    assign(socket,
      checked: true,
      user: user,
      site_id: id,
      pages: Enum.map(site.pages, fn page -> {page, Page.changeset(page, %{})} end),
      asset_pairs: Enum.map(site.assets, &{&1.name, &1.id}),
      changeset: Site.changeset(site, %{}),
      preview_url: Sites.preview_url(site, Application.get_env(:hosting, :sites_port)),
      canonical_url: canonical_url,
      port: Application.get_env(:hosting, :sites_port)
    )
    |> assign_page(nil)
    |> allow_upload(
      :stylesheet,
      accept: ~w(.css),
      max_entries: 1
    )
  end

  defp reset_site(%Site{} = site, socket) do
    {:noreply,
     assign(socket,
       changeset: Site.changeset(site, %{}),
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

  defp assign_page(socket, %Page{} = page) do
    assign(socket, page: page, page_changeset: Page.changeset(page, %{}))
  end

  defp assign_page(socket, nil) do
    assign(socket, page: nil, page_changeset: nil)
  end

  defp assign_preview_url(socket, preview_url, page_path) do
    uri =
      URI.parse(preview_url)
      |> Map.put(:query, "preview")
      |> Map.put(:path, page_path)

    assign(socket, preview_url: URI.to_string(uri))
  end
end
