defmodule AffiliateWeb.PageLive do
  use AffiliateWeb, :live_view

  alias Affiliate.SiteState

  @impl true
  def render(assigns) do
    Phoenix.View.render(AffiliateWeb.PageView, "page_live.html", assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    %{published: site} = SiteState.get()

    {:ok, assign_site(socket, site)}
  end

  defp assign_site(socket, site) do
    assign(socket,
      page_title: site["name"],
      header_image_url: site["header_image_url"],
      name: site["name"],
      logo_url: site["site_logo_url"],
      subtitle: site["page_subtitle"],
      text: site["text"],
      items: Map.get(site, "items", [])
    )
  end
end
