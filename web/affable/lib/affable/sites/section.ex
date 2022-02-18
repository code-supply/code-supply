defmodule Affable.Sites.Section do
  use Ecto.Schema
  import Ecto.Changeset

  alias Affable.{Assets, Layouts, Sites}

  @name_format ~r/^[a-z0-9-]*$/
  @colour_format ~r/^[A-F0-9]{6}$/

  @elements %{
    section: "section"
  }

  schema "sections" do
    belongs_to(:page, Sites.Page)
    belongs_to(:image, Assets.Asset)
    belongs_to(:layout, Layouts.Layout)

    field(:name, :string)
    field(:element, :string, default: @elements.section)
    field(:background_colour, :string, default: "FFFFFF")
    field(:text_colour, :string, default: "000000")
    field(:content, :string, default: "")

    timestamps()
  end

  def changeset(section, attrs) do
    section
    |> cast(
      attrs
      |> coerce_uppercase("text_colour")
      |> coerce_uppercase("background_colour"),
      [
        :name,
        :element,
        :background_colour,
        :text_colour,
        :content,
        :image_id
      ]
    )
    |> unique_constraint([:page_id, :name])
    |> validate_required([
      :name,
      :element,
      :background_colour,
      :text_colour
    ])
    |> validate_format(:name, @name_format)
    |> validate_format(:text_colour, @colour_format)
    |> validate_format(:background_colour, @colour_format)
  end

  defp coerce_uppercase(attrs, key) do
    if attrs[key] do
      attrs
      |> Map.put(key, attrs |> Map.get(key, "") |> String.upcase())
    else
      attrs
    end
  end
end
