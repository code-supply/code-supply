defmodule AffableWeb.PageController do
  use AffableWeb, :controller

  alias Affable.Pages

  defmodule MissingPage do
    defexception message: "could not find the page requested", plug_status: 404
  end

  def show(conn, _params) do
    %URI{host: host, path: path} = URI.parse(request_url(conn))

    case Pages.get_for_route(host, path) do
      nil ->
        raise MissingPage

      page ->
        # temporary to pass tests - replace with render of processed markup
        html(conn, "<html><title>#{page.site.name}</title></html>")
    end
  end
end
