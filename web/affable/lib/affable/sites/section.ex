defmodule Affable.Sites.Section do
  use Ecto.Schema
  import Ecto.Changeset

  alias Affable.Sites
  alias Affable.Assets

  @name_format ~r/^[a-z0-9-]*$/

  @elements %{
    section: "section"
  }

  schema "sections" do
    belongs_to(:page, Sites.Page)
    belongs_to(:image, Assets.Asset)

    field(:name, :string)
    field(:element, :string, default: @elements.section)
    field(:background_colour, :string, default: "FFFFFF")
    field(:text_colour, :string, default: "000000")
    field(:content, :string, default: "")

    timestamps()
  end

  def changeset(section, attrs) do
    section
    |> cast(attrs, [
      :name,
      :element,
      :background_colour,
      :content,
      :image_id
    ])
    |> unique_constraint([:page_id, :name])
    |> validate_required([
      :name,
      :element,
      :background_colour,
      :text_colour
    ])
    |> validate_format(:name, @name_format)
  end
end
