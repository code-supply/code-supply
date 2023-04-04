defmodule HostingWeb.StylesheetController do
  use HostingWeb, :controller

  alias Hosting.Sites
  alias Hosting.Sites.Site

  def show(conn, _params) do
    %URI{host: host} = URI.parse(request_url(conn))
    conn = put_resp_content_type(conn, "text/css")

    case Sites.get_for_host(host) do
      %Site{stylesheet: ""} ->
        send_resp(conn, 404, "")

      %Site{stylesheet: stylesheet} ->
        send_resp(conn, 200, stylesheet)
    end
  end
end
