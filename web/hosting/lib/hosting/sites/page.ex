defmodule Hosting.Sites.Page do
  use Ecto.Schema
  import Ecto.Changeset

  alias Hosting.Sites

  @path_format ~r/^\/[a-z0-9-_\+.]*$/

  schema "pages" do
    belongs_to(:site, Sites.Site)

    field(:title, :string)
    field(:path, :string, default: "/")
    field(:raw, :string)

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(
      attrs,
      [
        :title,
        :path,
        :raw
      ]
    )
    |> validate_required([
      :title,
      :path
    ])
    |> unique_constraint(:path, name: :pages_site_id_path_index)
    |> validate_format(:path, @path_format)
  end
end