defmodule AffableWeb.InnerPageComponent do
  use AffableWeb, :live_component

  def update(assigns, socket) do
    {:ok,
     assign(socket,
       site: assigns.site,
       page: assigns.page,
       menu: menu(assigns.site.pages)
     )}
  end

  def menu(pages) do
    for page <- pages do
      %{path: page.path, name: page.title}
    end
  end

  def section_style(section) do
    Enum.join(AffableWeb.DynamicStyle.as_list(section), ";")
  end
end
