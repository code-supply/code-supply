defmodule AffiliateWeb.PageLive do
  use AffiliateWeb, :live_view

  alias Affiliate.SiteState

  @impl true
  def mount(_params, _session, socket) do
    node = inspect(node())
    nodes = inspect(Node.list())
    {pubsub, topic} = SiteState.subscription_info()
    %{name: _} = site = SiteState.site()
    Phoenix.PubSub.subscribe(pubsub, topic)
    {:ok, assign(socket, node: node, nodes: nodes, site: site, page_title: site.name)}
  end

  @impl true
  def handle_info(site, socket) do
    {:noreply, assign(socket, site: site, page_title: site.name)}
  end

  def format_price(nil) do
    ""
  end

  def format_price(price) do
    price |> Decimal.to_string()
  end
end
