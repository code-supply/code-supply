defmodule AffableWeb.PageLive do
  use AffableWeb, :live_view

  @impl true
  def mount(_params, %{}, socket) do
    {:ok, socket}
  end
end
