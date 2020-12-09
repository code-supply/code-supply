defmodule AffableWeb.AssetsLive do
  use AffableWeb, :live_view

  alias Affable.Accounts

  @impl true
  def mount(_params, %{"user_token" => token}, socket) do
    if connected?(socket) do
    end

    {:ok, socket}
  end
end
