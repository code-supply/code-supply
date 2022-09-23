defmodule Affable.Pages do
  import Ecto.Query, warn: false

  alias Affable.Repo
  alias Affable.Sites.Page

  def stripped(%Page{raw: raw}) do
    {:ok, doc} = Floki.parse_document(raw)

    doc
    |> Floki.filter_out("script")
    |> Floki.filter_out("link[rel=stylesheet i]")
    |> Floki.raw_html()
  end

  def get_for_route(host, path) do
    Repo.one(
      from(p in Page,
        join: s in assoc(p, :site),
        join: d in assoc(s, :domains),
        where: d.name == ^host and p.path == ^path,
        preload: [site: [pages: []]]
      )
    )
  end
end
