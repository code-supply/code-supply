defmodule AffableWeb.LayoutEditorComponent do
  use AffableWeb, :live_component

  import Affable.Layouts, only: [row_resize?: 1]

  alias Affable.Layouts

  def update(%{id: id, user: user}, socket) do
    layout = Layouts.get!(user, id)

    {:ok,
     assign(socket,
       user: user,
       layout: layout,
       sections: Layouts.editor_sections(layout),
       editor_grid_template_areas: Layouts.editor_grid_template_areas(layout),
       preview_grid_template_rows: layout.grid_template_rows,
       editor_grid_template_rows: Layouts.editor_grid_template_rows(layout.grid_template_rows)
     )}
  end

  def handle_event(
        "resizeRowDrag",
        %{"row" => row, "offset" => offset},
        %{assigns: %{preview_grid_template_rows: grid_template_rows}} = socket
      ) do
    grid_template_rows = Layouts.resize_grid_template_row(grid_template_rows, row, offset)

    {:noreply,
     assign(
       socket,
       preview_grid_template_rows: grid_template_rows,
       editor_grid_template_rows: Layouts.editor_grid_template_rows(grid_template_rows)
     )}
  end

  def handle_event(
        "resizeRow",
        %{},
        %{assigns: %{preview_grid_template_rows: grid_template_rows, layout: layout, user: user}} =
          socket
      ) do
    {:ok, layout} = Layouts.update(user, layout, %{grid_template_rows: grid_template_rows})

    {:noreply,
     assign(
       socket,
       layout: layout
     )}
  end
end
