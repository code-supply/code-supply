defmodule Affable.Sites.Site do
  use Ecto.Schema
  import Ecto.Changeset

  alias Affable.Domains.Domain
  alias Affable.Assets.Asset
  alias Affable.Sites.{Item, Publication, SiteMember, AttributeDefinition}

  @colour_format ~r/[A-F0-9]{6}/

  schema "sites" do
    field :name, :string
    belongs_to :site_logo, Asset
    belongs_to :header_image, Asset
    field :page_subtitle, :string
    field :text, :string
    field :internal_name, :string
    field :internal_hostname, :string
    field :made_available_at, :utc_datetime
    field :cta_text, :string, default: "Go"
    field :cta_background_colour, :string, default: "059669"
    field :cta_text_colour, :string, default: "FFFFFF"
    field :header_background_colour, :string, default: "3B82F6"
    field :header_text_colour, :string, default: "FFFFFF"
    field :custom_head_html, :string, default: ""
    field :load_balancer_index, :integer
    has_many :assets, Asset
    has_many :members, SiteMember
    has_many :users, through: [:members, :user]
    has_many :domains, Domain
    has_many :items, Item
    has_many :attribute_definitions, AttributeDefinition
    has_many :publications, Publication
    has_one :latest_publication, Publication

    timestamps()
  end

  @doc false
  def changeset(site, attrs) do
    site
    |> cast(
      attrs
      |> coerce_uppercase("cta_text_colour")
      |> coerce_uppercase("cta_background_colour")
      |> coerce_uppercase("header_text_colour")
      |> coerce_uppercase("header_background_colour"),
      [
        :name,
        :site_logo_id,
        :header_image_id,
        :page_subtitle,
        :text,
        :cta_text,
        :cta_text_colour,
        :cta_background_colour,
        :header_background_colour,
        :header_text_colour,
        :custom_head_html
      ]
    )
    |> cast_assoc(:items, with: &Item.changeset/2)
    |> cast_assoc(:attribute_definitions, with: &AttributeDefinition.changeset/2)
    |> validate_required([
      :name,
      :cta_text,
      :cta_text_colour,
      :cta_background_colour,
      :header_background_colour,
      :header_text_colour
    ])
    |> validate_format(:cta_text_colour, @colour_format)
    |> validate_format(:cta_background_colour, @colour_format)
    |> validate_format(:header_background_colour, @colour_format)
    |> validate_format(:header_text_colour, @colour_format)
  end

  def change_load_balancer(site, index) do
    site
    |> cast(%{load_balancer_index: index}, [:load_balancer_index])
  end

  def change_internal_name(site, internal_name) do
    site
    |> cast(%{internal_name: internal_name, internal_hostname: "app.#{internal_name}"}, [
      :internal_name,
      :internal_hostname
    ])
    |> validate_required([:internal_name, :internal_hostname])
  end

  def change_made_available_at(site, time) do
    site
    |> cast(%{made_available_at: time}, [:made_available_at])
    |> validate_required([:made_available_at])
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
