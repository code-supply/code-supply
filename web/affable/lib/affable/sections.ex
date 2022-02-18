defmodule Affable.Sections do
  import Ecto.Query, warn: false

  alias Affable.Repo
  alias Affable.Layouts.Layout
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
      {
        :ok,
        section
        |> broadcast()
      }
    else
      err -> err
    end
  end

  defp broadcast(%Section{} = section) do
    site = (section |> Repo.preload(layout: :site)).layout.site
    Affable.Sites.broadcast(site)
    section
  end
end
