defmodule AffableWeb.PageLive do
  use AffableWeb, :live_view

  alias Affable.Pages

  defmodule MissingPage do
    defexception message: "could not find the page requested", plug_status: 404
  end

  @impl true
  def mount(_params, _things, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, uri, socket) do
    %URI{host: host, path: path} = URI.parse(uri)

    case Pages.get_for_route(host, path) do
      nil ->
        raise MissingPage

      page ->
        {:noreply,
         assign(
           socket,
           site: page.site,
           page: page,
           page_title: page.site.name
         )}
    end
  end
end
