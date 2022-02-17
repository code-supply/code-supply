defmodule AffableWeb.LayoutEditorComponent do
  use AffableWeb, :live_component

  import Affable.Layouts, only: [column_resize?: 1, row_resize?: 1]

  alias Affable.Layouts
  alias Affable.Sites.Section

  def update(%{id: id, user: user}, socket) do
    layout = Layouts.get!(user, id)
    grid = Layouts.editor_grid(layout)

    {:ok,
     assign(socket,
       user: user,
       layout: layout,
       sections:
         for {data_attrs, section} <- Layouts.sections(grid, layout.sections) do
           {Keyword.new(data_attrs), section, Section.changeset(section, %{})}
         end,
       editor_grid_template_areas: Layouts.format_areas(grid),
       editor_grid_template_rows: Layouts.format_measurements(grid.rows),
       editor_grid_template_columns: Layouts.format_measurements(grid.columns)
     )}
  end

  def handle_event(
        "resizeRow",
        %{"row" => row, "height" => height},
        %{assigns: %{layout: layout, user: user}} = socket
      ) do
    handle_resize(socket, layout, user, row, height, :grid_template_rows)
  end

  def handle_event(
        "resizeColumn",
        %{"column" => column, "width" => width},
        %{assigns: %{layout: layout, user: user}} = socket
      ) do
    handle_resize(socket, layout, user, column, width, :grid_template_columns)
  end

  def handle_event(
        "save",
        %{"section" => params},
        %{assigns: %{user: user}} = socket
      ) do
    {:ok, section} = Layouts.update_section(user, params)

    {:noreply,
     update(socket, :sections, fn sections ->
       for {data_attrs, existing_section, _changeset} = entry <- sections do
         if existing_section.id == section.id do
           {data_attrs, section, Section.changeset(section, %{})}
         else
           entry
         end
       end
     end)}
  end

  def resize_hooks(myself, section) do
    cond do
      row_resize?(section) ->
        [phx_target: myself, phx_hook: "RowResize"]

      column_resize?(section) ->
        [phx_target: myself, phx_hook: "ColumnResize"]

      true ->
        []
    end
  end

  defp handle_resize(socket, layout, user, pos, size, attr) do
    original_sizes = Map.get(layout, attr)
    sizes = Layouts.change_grid_template_size(original_sizes, pos, size)

    {:ok, layout} = Layouts.update(user, layout, %{"#{attr}": sizes})

    {:noreply,
     assign(
       socket,
       "editor_#{attr}": apply(Layouts, :"editor_#{attr}", [layout]),
       layout: layout
     )}
  end
end
