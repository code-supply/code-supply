defmodule HostingWeb.PageComponent do
  use HostingWeb, :live_component

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(markup: assigns.markup)}
  end
end