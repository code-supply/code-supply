defmodule HostingWeb.PresignedUploadController do
  use HostingWeb, :controller

  alias Hosting.Uploader

  def show(conn, _) do
    render(conn, :show, meta: Uploader.presign_upload("foo"))
  end
end
