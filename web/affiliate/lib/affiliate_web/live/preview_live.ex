defmodule AffiliateWeb.PreviewLive do
  use AffiliateWeb, :live_view

  import AffiliateWeb.PageShared

  @key :preview

  @impl true
  def render(assigns) do
    Phoenix.View.render(AffiliateWeb.PageView, "page_live.html", assigns)
  end

  @impl true
  def mount(%{"path" => path_parts}, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Affiliate.PubSub, "updates")
    end

    {:ok,
     socket
     |> assign_path(path_parts)
     |> assign_state(@key, Affiliate.SiteState.get())}
  end

  @impl true
  def handle_info(state, socket) do
    {:noreply, socket |> assign_state(@key, state)}
  end
end
