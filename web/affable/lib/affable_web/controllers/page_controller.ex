defmodule AffableWeb.PageController do
  use AffableWeb, :controller

  alias Affable.Pages
  alias Plug.Conn

  defmodule MissingPage do
    defexception [:message, :plug_status]

    @impl true
    def exception(path) do
      msg = "could not find the path '#{path}'"
      %MissingPage{message: msg, plug_status: 404}
    end
  end

  def show(conn, _params) do
    %URI{host: host, path: path} = URI.parse(request_url(conn))

    case Pages.get_for_route(host, path) do
      nil ->
        raise MissingPage, path

      page ->
        html(
          conn
          |> Conn.delete_resp_header("x-frame-options")
          |> Conn.put_resp_header(
            "content-security-policy",
            "frame-ancestors #{frame_ancestor()}"
          ),
          page.raw
        )
    end
  end

  defp frame_ancestor() do
    Application.get_env(:affable, :frame_ancestor)
  end
end
