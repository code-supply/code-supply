defmodule AffableWeb.PageLive do
  use AffableWeb, :live_view

  @impl true
  def mount(_params, _things, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, uri, socket) do
    %URI{host: host} = URI.parse(uri)
    {:noreply, assign(socket, host: host)}
  end

  def section_style(section) do
    Enum.join(AffableWeb.DynamicStyle.as_list(section), ";")
  end
end
