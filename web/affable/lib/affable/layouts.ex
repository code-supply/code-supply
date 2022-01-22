defmodule Affable.Layouts do
  import Ecto.Query, warn: false

  alias Affable.Repo
  alias Affable.Layouts.Layout
  alias Affable.Sites
  alias Affable.Sites.{Section, SiteMember}

  @default_template_areas ~s("header header"
"nav main"
"footer footer")
  @default_template_rows ~s(50px 1fr 50px)
  @default_template_columns ~s(150px 1fr)

  def resize_bar_width do
    ~s(20px)
  end

  def row_resize?(%Section{id: "rowadjust" <> _}) do
    true
  end

  def row_resize?(_) do
    false
  end

  def editor_sections(layout) do
    layout
    |> deserialised_editor_grid_template_areas()
    |> Enum.flat_map(&Enum.uniq(&1))
  end

  def editor_grid_template_areas(layout) do
    layout
    |> deserialised_editor_grid_template_areas()
    |> serialise_areas()
  end

  defp deserialised_editor_grid_template_areas(layout) do
    rows = deserialise_areas(layout)
    [first_row | _] = rows
    column_count = length(first_row)
    row_count = length(rows)

    for {row, row_index} <- Enum.with_index(rows), reduce: [] do
      acc ->
        acc ++
          for r <- with_adjustment_row(row, row_index, row_count, column_count) do
            indexed_cells(r, row_index)
          end
    end
  end

  defp with_adjustment_row(row, row_index, row_count, column_count) do
    [row] ++
      if row_index == row_count - 1 do
        []
      else
        [adjustment_row(column_count, row_index)]
      end
  end

  defp indexed_cells(row, row_index) do
    for cell <- row do
      {row_index, cell}
    end
  end

  defp adjustment_row(column_count, row_index) do
    for _ <- 1..column_count do
      %Section{
        id: "rowadjust#{row_index}",
        name: "_rowadjust#{row_index}",
        element: "div"
      }
    end
  end

  def editor_grid_template_rows(nil) do
    ""
  end

  def editor_grid_template_rows(str_rows) do
    original_cols = String.split(str_rows)

    original_cols
    |> Enum.map(fn col_size ->
      ~s{calc(#{col_size} - #{resize_bar_width()}) #{resize_bar_width()}}
    end)
    |> List.replace_at(length(original_cols) - 1, List.last(original_cols))
    |> Enum.join(" ")
  end

  defp deserialise_areas(%Layout{grid_template_areas: nil}) do
    [[]]
  end

  defp deserialise_areas(%Layout{grid_template_areas: grid_template_areas, sections: sections}) do
    for row <- String.split(grid_template_areas, "\n") do
      for col <- String.split(row) do
        name = col |> String.trim() |> String.replace(~s("), "")
        sections |> Enum.find(fn s -> s.name == name end)
      end
    end
  end

  defp serialise_areas(arranged_sections) do
    for row <- arranged_sections do
      row
      |> Enum.map(&elem(&1, 1).name)
      |> Enum.join(" ")
    end
    |> Enum.map(fn w -> ~s("#{w}") end)
    |> Enum.join("\n")
  end

  def get!(user, id) do
    from(l in Layout, where: l.id == ^id, preload: [:sections])
    |> join(:inner, [l], m in SiteMember, on: l.site_id == m.site_id)
    |> where([s, m], m.user_id == ^user.id)
    |> Repo.one!()
  end

  def create_layout(site, attrs) do
    sections = [
      %Section{name: "header", element: "header", background_colour: "000000"},
      %Section{name: "nav", element: "nav", background_colour: "00FF00"},
      %Section{name: "main", element: "main", background_colour: "0000FF"},
      %Section{name: "footer", element: "footer", background_colour: "FFFF00"}
    ]

    site
    |> Ecto.build_assoc(
      :layouts,
      attrs
      |> Enum.into(%{
        site_id: site.id,
        sections: sections,
        grid_template_areas: @default_template_areas,
        grid_template_rows: @default_template_rows,
        grid_template_columns: @default_template_columns
      })
    )
    |> Repo.insert()
  end

  def resize_grid_template_row(rows, row_index, offset) do
    rows
    |> String.split()
    |> List.update_at(String.to_integer(row_index), fn height ->
      case Integer.parse(height) do
        {height, _junk} ->
          new_height = height + offset
          "#{new_height}px"

        err ->
          IO.inspect(height)
          IO.inspect(err)
      end
    end)
    |> Enum.join(" ")
  end

  def update(user, layout, attrs) do
    with :ok <- Sites.must_be_site_member(user, layout) do
      {:ok, layout} =
        layout
        |> Layout.changeset(attrs)
        |> Repo.update()
        |> broadcast()

      {:ok, layout}
    else
      err -> err
    end
  end

  def all() do
    Repo.all(from(l in Layout, preload: [:sections]))
  end

  defp broadcast({:ok, %Layout{} = layout}) do
    site = Affable.Sites.get_site!(layout.site_id)
    Affable.Sites.broadcast(site)

    {:ok, layout}
  end
end
