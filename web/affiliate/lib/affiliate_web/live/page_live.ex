defmodule AffiliateWeb.PageLive do
  use AffiliateWeb, :live_view

  alias Affiliate.SiteState

  import AffiliateWeb.PageShared

  @key :published

  @impl true
  def render(assigns) do
    Phoenix.View.render(AffiliateWeb.PageView, "page_live.html", assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Affiliate.PubSub, "updates")
    end

    %{@key => site} = SiteState.get()

    {:ok, assign_site(socket, site)}
  end

  @impl true
  def handle_info(%{@key => site}, socket) do
    {:noreply, assign_site(socket, site)}
  end
end
