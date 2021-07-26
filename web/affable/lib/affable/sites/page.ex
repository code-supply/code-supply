defmodule Affable.Sites.Page do
  use Ecto.Schema
  import Ecto.Changeset

  alias Affable.Sites.Site
  alias Affable.Assets.Asset

  @colour_format ~r/[A-F0-9]{6}/

  schema "pages" do
    belongs_to :site, Site
    belongs_to :header_image, Asset

    field :title, :string
    field :meta_description, :string, default: ""

    field :text, :string, default: ""
    field :header_text, :string, default: ""
    field :cta_text, :string, default: "Go"

    field :cta_background_colour, :string, default: "059669"
    field :cta_text_colour, :string, default: "FFFFFF"
    field :header_background_colour, :string, default: "3B82F6"
    field :header_text_colour, :string, default: "FFFFFF"

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(
      attrs
      |> coerce_uppercase("cta_text_colour")
      |> coerce_uppercase("cta_background_colour")
      |> coerce_uppercase("header_text_colour")
      |> coerce_uppercase("header_background_colour"),
      [
        :title,
        :meta_description,
        :header_image_id,
        :header_text,
        :header_background_colour,
        :header_text_colour,
        :text,
        :cta_background_colour,
        :cta_text_colour,
        :cta_text
      ]
    )
    |> validate_required([
      :title,
      :header_background_colour,
      :header_text_colour,
      :cta_background_colour,
      :cta_text_colour,
      :cta_text
    ])
    |> validate_format(:cta_text_colour, @colour_format)
    |> validate_format(:cta_background_colour, @colour_format)
    |> validate_format(:header_background_colour, @colour_format)
    |> validate_format(:header_text_colour, @colour_format)
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
