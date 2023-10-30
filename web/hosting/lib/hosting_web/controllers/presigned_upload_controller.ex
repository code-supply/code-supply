defmodule HostingWeb.PresignedUploadController do
  use HostingWeb, :controller

  alias Hosting.Uploader

  def show(conn, %{"id" => site_id}) do
    site = Hosting.Sites.get_site!(site_id) |> Hosting.Repo.preload(:users)
    api_keys = for user <- site.users, do: user.api_key

    headers = Enum.into(conn.req_headers, %{})
    [_, provided_api_key] = String.split(headers["authorization"])

    if provided_api_key in api_keys do
      render(conn, :show, meta: Uploader.presign_upload("foo"))
    else
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(401, Jason.encode!("Invalid API key"))
    end
  end
end
