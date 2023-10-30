defmodule HostingWeb.PresignedUploadView do
  def show(%{meta: meta, conn: _conn}) do
    meta
  end
end
