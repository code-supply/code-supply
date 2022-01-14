defmodule Affable.Layouts do
  import Ecto.Query, warn: false

  alias Affable.Repo

  alias Affable.Layouts.Layout
  alias Affable.Sites
  alias Affable.Sites.Section

  @default_template_areas ~s("header header"
"nav main"
"footer footer")
  @default_template_rows ~s(50px 1fr 50px)
  @default_template_columns ~s(150px 1fr)

  def create_layout(site, %{name: name}) do
    sections = [
      %Section{name: "header", element: "header", background_colour: "000000"},
      %Section{name: "nav", element: "nav", background_colour: "00FF00"},
      %Section{name: "main", element: "main", background_colour: "0000FF"},
      %Section{name: "footer", element: "footer", background_colour: "FFFF00"}
    ]

    site
    |> Ecto.build_assoc(:layouts, %{
      name: name,
      sections: sections,
      grid_template_areas: @default_template_areas,
      grid_template_rows: @default_template_rows,
      grid_template_columns: @default_template_columns
    })
    |> Repo.insert()
  end

  def resize(user, layout, section_name: _section_name, x: _x, y: y) do
    with :ok <- Sites.must_be_site_member(user, layout),
         {:ok, layout} =
           layout
           |> Layout.changeset(%{grid_template_rows: "50px #{y}px 50px"})
           |> Repo.update() do
      {:ok, layout}
    else
      err -> err
    end
  end

  def all() do
    Repo.all(from(l in Layout, preload: [:sections]))
  end
end
