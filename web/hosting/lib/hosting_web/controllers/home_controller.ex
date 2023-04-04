defmodule HostingWeb.HomeController do
  use HostingWeb, :controller

  def show(conn, _params) do
    render(conn, :show)
  end
end
