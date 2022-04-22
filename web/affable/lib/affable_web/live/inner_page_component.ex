defmodule AffableWeb.InnerPageComponent do
  use AffableWeb, :live_component

  def update(assigns, socket) do
    {:ok,
     assign(socket,
       site: assigns.site,
       page: assigns.page,
       menu: menu(assigns.site.pages),
       sections_style: sections_style(assigns.site.layout)
     )}
  end

  defp sections_style(%{
         grid_template_areas: grid_template_areas,
         grid_template_rows: grid_template_rows,
         grid_template_columns: grid_template_columns
       }) do
    """
      grid-template-areas: #{grid_template_areas};
      grid-template-rows: #{grid_template_rows};
      grid-template-columns: #{grid_template_columns};
    """
  end

  defp sections_style(nil) do
    nil
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
