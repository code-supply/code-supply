defmodule Affable.Sites.Page do
  use Ecto.Schema
  import Ecto.Changeset

  alias Affable.Sites
  alias Affable.Assets

  @path_format ~r/^\/[a-z0-9-_\+]*$/

  schema "pages" do
    belongs_to(:site, Sites.Site)
    has_many(:sections, Sites.Section)

    field(:title, :string)
    field(:meta_description, :string, default: "")
    field(:path, :string, default: "/")

    field(:grid_template_areas, :string, default: "")
    field(:grid_template_rows, :string, default: "")
    field(:grid_template_columns, :string, default: "")

    field(:text, :string, default: "")

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(
      attrs,
      [
        :title,
        :meta_description,
        :path,
        :grid_template_areas,
        :grid_template_rows,
        :grid_template_columns,
        :text
      ]
    )
    |> cast_assoc(:sections, with: &Sites.Section.changeset/2)
    |> validate_required([
      :title,
      :path
    ])
    |> unique_constraint(:path, name: :pages_site_id_path_index)
    |> validate_format(:path, @path_format)
  end
end
