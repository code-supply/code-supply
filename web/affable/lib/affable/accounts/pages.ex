defmodule Affable.Pages do
  import Ecto.Query, warn: false

  alias Affable.Repo
  alias Affable.Sites.Page

  def get(host, path) do
    Repo.one(
      from(p in Page,
        join: s in assoc(p, :site),
        join: d in assoc(s, :domains),
        where: d.name == ^host
      )
    )
  end
end
