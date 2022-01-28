defmodule AffableWeb.LayoutEditorComponent do
  use AffableWeb, :live_component

  import Affable.Layouts, only: [column_resize?: 1, row_resize?: 1]

  alias Affable.Layouts

  def update(%{id: id, user: user}, socket) do
    layout = Layouts.get!(user, id)
    grid = Layouts.editor_grid(layout)

    {:ok,
     assign(socket,
       user: user,
       layout: layout,
       sections: Layouts.sections(grid, layout.sections),
       editor_grid_template_areas: Layouts.format_areas(grid),
       preview_grid_template_rows: layout.grid_template_rows,
       editor_grid_template_rows: Layouts.format_measurements(grid.rows),
       editor_grid_template_columns: Layouts.format_measurements(grid.columns)
     )}
  end

  def handle_event(
        "resizeRow",
        %{"row" => row, "height" => height},
        %{assigns: %{preview_grid_template_rows: grid_template_rows, layout: layout, user: user}} =
          socket
      ) do
    grid_template_rows = Layouts.resize_grid_template_row(grid_template_rows, row, height)
    {:ok, layout} = Layouts.update(user, layout, %{grid_template_rows: grid_template_rows})

    {:noreply,
     assign(
       socket,
       preview_grid_template_rows: grid_template_rows,
       editor_grid_template_rows: Layouts.editor_grid_template_rows(layout),
       layout: layout
     )}
  end
end
