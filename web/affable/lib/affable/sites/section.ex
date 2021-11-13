defmodule Affable.Sites.Section do
  use Ecto.Schema
  import Ecto.Changeset

  @elements %{
    section: "section"
  }

  embedded_schema do
    field(:name, :string)
    field(:element, :string, default: @elements.section)
    field(:grid_area, :string, default: "content")
    field(:background_colour, :string, default: "FFFFFF")
  end

  def changeset(section, attrs) do
    section
    |> cast(attrs, [:name, :element, :grid_area, :background_colour])
    |> validate_required([
      :name,
      :element,
      :grid_area,
      :background_colour
    ])
  end
end
