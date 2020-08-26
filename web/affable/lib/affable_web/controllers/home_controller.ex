defmodule AffableWeb.HomeController do
  use AffableWeb, :controller

  def show(conn, _params) do
    node = inspect(node())
    nodes = inspect(Node.list())
    render(conn, "show.html", node: node, nodes: nodes)
  end
end
