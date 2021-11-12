defmodule Affable.Sites.Page do
  use Ecto.Schema
  import Ecto.Changeset

  alias Affable.Sites
  alias Affable.Assets

  @path_format ~r/^\/[a-z0-9-_\+]*$/
  @colour_format ~r/^[A-F0-9]{6}$/

  schema "pages" do
    belongs_to(:site, Sites.Site)
    belongs_to(:header_image, Assets.Asset)
    has_many(:items, Sites.Item)
    embeds_many(:sections, Sites.Section)

    field(:title, :string)
    field(:meta_description, :string, default: "")
    field(:path, :string, default: "/")

    field(:text, :string, default: "")
    field(:header_text, :string, default: "")
    field(:cta_text, :string, default: "Go")

    field(:cta_background_colour, :string, default: "059669")
    field(:cta_text_colour, :string, default: "FFFFFF")
    field(:header_background_colour, :string, default: "3B82F6")
    field(:header_text_colour, :string, default: "FFFFFF")

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
        :path,
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
    |> cast_assoc(:items, with: &Sites.Item.changeset/2)
    |> cast_embed(:sections)
    |> validate_required([
      :title,
      :path,
      :header_background_colour,
      :header_text_colour,
      :cta_background_colour,
      :cta_text_colour,
      :cta_text
    ])
    |> unique_constraint(:path, name: :pages_site_id_path_index)
    |> validate_format(:path, @path_format)
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
