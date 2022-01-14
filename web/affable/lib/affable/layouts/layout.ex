defmodule Affable.Layouts.Layout do
  use Ecto.Schema
  import Ecto.Changeset

  alias Affable.Sites.{Section, Site}

  schema "layouts" do
    field(:name, :string)
    field(:grid_template_areas, :string, default: "")
    field(:grid_template_rows, :string, default: "")
    field(:grid_template_columns, :string, default: "")

    belongs_to(:site, Site)
    has_many :sections, Section

    timestamps()
  end

  @doc false
  def changeset(layout, attrs) do
    layout
    |> cast(attrs, [:name, :grid_template_rows])
    |> validate_required([:name])
  end
end
