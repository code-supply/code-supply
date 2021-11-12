defmodule Affable.Sites.Section do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :name, :string
    field :element, :string
    field :grid_area, :string
    field :background_colour, :string, default: "FFFFFF"
  end

  def changeset(section, attrs) do
    section
    |> cast(attrs, [:name, :element, :grid_area, :background_colour])
  end
end
