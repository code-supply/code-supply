defmodule AffableWeb.HomeController do
  use AffableWeb, :controller

  def show(conn, _params) do
    render(conn, "show.html")
  end
end
