defmodule AffiliateWeb.PreviewLive do
  use AffiliateWeb, :live_view

  alias Affiliate.SiteState

  @key :preview

  @impl true
  def render(assigns) do
    Phoenix.View.render(AffiliateWeb.PageView, "page_live.html", assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    {pubsub, topic} = SiteState.subscription_info()
    %{@key => site} = SiteState.get()
    Phoenix.PubSub.subscribe(pubsub, topic)

    {:ok, assign_site(socket, site)}
  end

  @impl true
  def handle_info(%{@key => site}, socket) do
    {:noreply, assign_site(socket, site)}
  end

  @impl true
  def handle_info(%{append: %{item: item}}, socket) do
    {:noreply, update(socket, :items, &(&1 ++ [item]))}
  end

  defp assign_site(socket, site) do
    assign(socket,
      header_image_url: site["header_image_url"],
      name: site["name"],
      logo_url: site["site_logo_url"],
      subtitle: site["page_subtitle"],
      text: site["text"],
      items: site["items"]
    )
  end
end
