defmodule Affable.Layouts do
  import Ecto.Query, warn: false

  alias Affable.CssGrid
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

  def column_resize?(%Section{name: "_adjustcolumn" <> _}) do
    true
  end

  def column_resize?(_) do
    false
  end

  def row_resize?(%Section{name: "_adjustrow" <> _}) do
    true
  end

  def row_resize?(_) do
    false
  end

  def editor_grid(layout) do
    layout
    |> layout_to_css_grid()
    |> CssGrid.add_adjusters()
  end

  def format_areas(grid) do
    grid.areas
    |> Enum.map(fn row -> ~s(") <> Enum.join(row, " ") <> ~s(") end)
    |> Enum.join("\n")
  end

  def format_measurements(measurements) do
    measurements |> Enum.join(" ")
  end

  def sections(grid, sections) do
    for {name, {last_col, last_row}} <- CssGrid.names_with_coords(grid.areas) do
      section = Enum.find(sections, &(&1.name == name))

      {
        %{
          last_col: last_col,
          last_row: last_row,
          editor_pos: CssGrid.editor_pos(name),
          original_pos: CssGrid.original_pos(name)
        },
        section || %Section{name: name}
      }
    end
  end

  def editor_grid_template_areas(%Layout{grid_template_areas: nil}) do
    ~s("")
  end

  defp layout_to_css_grid(%Layout{
         grid_template_areas: areas,
         grid_template_columns: columns,
         grid_template_rows: rows
       }) do
    %CssGrid{
      bar: resize_bar_width(),
      areas: areas |> areas_to_list(),
      columns: columns |> String.split(),
      rows: (rows || "") |> String.split()
    }
  end

  @spec areas_to_list(nil | String.t()) :: list(list(String.t()))
  defp areas_to_list(nil) do
    [[]]
  end

  defp areas_to_list(areas) do
    areas
    |> String.split("\n")
    |> Enum.map(fn row -> row |> String.replace(~s("), "") |> String.split() end)
  end

  def editor_grid_template_columns(nil) do
    ""
  end

  def editor_grid_template_columns("") do
    ""
  end

  def editor_grid_template_columns(layout) do
    grid =
      layout
      |> layout_to_css_grid()
      |> CssGrid.add_adjusters()

    grid.columns |> Enum.join(" ")
  end

  def editor_grid_template_rows(nil) do
    ""
  end

  def editor_grid_template_rows("") do
    ""
  end

  def editor_grid_template_rows(layout) do
    grid =
      layout
      |> layout_to_css_grid()
      |> CssGrid.add_adjusters()

    grid.rows |> Enum.join(" ")
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

  def change_grid_template_size(sizes, index, new_size) do
    sizes
    |> String.split()
    |> List.replace_at(String.to_integer(index), "#{new_size}px")
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
