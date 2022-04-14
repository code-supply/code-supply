defmodule Affable.Sections do
  import Ecto.Query, warn: false
  import Affable.Layouts, only: [layout_to_css_grid: 1, format_areas: 1]
  import Affable.CssGrid, only: [delete_area: 2]

  alias Affable.Repo
  alias Affable.Layouts.Layout
  alias Affable.Sites
  alias Affable.Sites.Page
  alias Affable.Sites.Section
  alias Affable.Sites.SiteMember

  def get!(user, id) do
    from(s in Section)
    |> where([s], s.id == ^id)
    |> join(:left, [s], p in Page, on: s.page_id == p.id)
    |> join(:left, [s, p], l in Layout, on: s.layout_id == l.id)
    |> join(:inner, [s, p, l], m in SiteMember,
      on: m.site_id == l.site_id or m.site_id == p.site_id
    )
    |> where([s, p, l, m], m.user_id == ^user.id)
    |> Repo.one!()
  end

  def update(section, attrs) do
    with {:ok, section} <-
           section
           |> Section.changeset(attrs)
           |> Repo.update() do
      {:ok, section}
    else
      err -> err
    end
  end

  def delete(section) do
    layout = Repo.get!(Layout, section.layout_id)

    css_grid =
      layout_to_css_grid(layout)
      |> delete_area(section.name)

    layout_changeset =
      Layout.changeset(layout, %{
        grid_template_areas: format_areas(css_grid),
        grid_template_rows: css_grid.rows |> Enum.join(" "),
        grid_template_columns: css_grid.columns |> Enum.join(" ")
      })

    Ecto.Multi.new()
    |> Ecto.Multi.delete(:delete, section)
    |> Ecto.Multi.update(:remove_from_grid_template_areas, layout_changeset)
    |> Repo.transaction()

    Sites.get_site!(Repo.preload(section, layout: :site).layout.site_id)

    :ok
  end
end
