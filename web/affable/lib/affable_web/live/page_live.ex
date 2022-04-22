defmodule AffableWeb.PageLive do
  use AffableWeb, :live_view

  alias Affable.Pages

  import Affable.Assets, only: [to_imgproxy_url: 1]

  @impl true
  def mount(_params, _things, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, uri, socket) do
    %URI{host: host, path: path} = URI.parse(uri)
    page = Pages.get(host, path)

    {:noreply,
     assign(
       socket,
       site: page.site,
       layout_sections:
         if page.site.layout do
           page.site.layout.sections
         else
           []
         end,
       sections: page.sections,
       menu:
         for page <- page.site.pages do
           %{path: page.path, name: page.title}
         end,
       page_layout: page.site.layout,
       page: page,
       page_title: page.site.name
     )}
  end

  def grid_style(%{
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

  def section_style(section) do
    Enum.join(AffableWeb.DynamicStyle.as_list(section), ";")
  end
end
