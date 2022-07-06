defmodule AffableWeb.PageComponent do
  use AffableWeb, :live_component

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(markup: assigns.markup)}
  end
end
