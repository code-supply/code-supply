defmodule AffiliateWeb.PageLive do
  use AffiliateWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    node = inspect(node())
    nodes = inspect(Node.list())
    {:ok, assign(socket, node: node, nodes: nodes)}
  end
end
