defmodule AffableWeb.AssetsLive do
  use AffableWeb, :live_view

  @impl true
  def mount(_params, %{"user_token" => _token}, socket) do
    if connected?(socket) do
    end

    {:ok, socket}
  end
end
