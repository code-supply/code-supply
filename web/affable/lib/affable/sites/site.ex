defmodule Affable.Sites.Site do
  use Ecto.Schema
  import Ecto.Changeset

  alias Affable.Domains.Domain
  alias Affable.Assets.Asset
  alias Affable.Layouts.Layout
  alias Affable.Sites.{Page, Publication, SiteMember, AttributeDefinition}

  schema "sites" do
    field :name, :string
    belongs_to :site_logo, Asset

    # chosen global layout for site
    belongs_to :layout, Layout
    # available layouts, created by any site member
    has_many :layouts, Layout

    field :internal_name, :string
    field :internal_hostname, :string
    field :made_available_at, :utc_datetime
    field :custom_head_html, :string, default: ""
    has_many :pages, Page
    has_many :assets, Asset
    has_many :members, SiteMember
    has_many :users, through: [:members, :user]
    has_many :domains, Domain
    has_many :attribute_definitions, AttributeDefinition
    has_many :publications, Publication

    has_one :latest_publication, Publication

    timestamps()
  end

  @doc false
  def changeset(site, attrs) do
    site
    |> cast(
      attrs,
      [
        :name,
        :layout_id,
        :site_logo_id,
        :custom_head_html
      ]
    )
    |> cast_assoc(:attribute_definitions, with: &AttributeDefinition.changeset/2)
    |> validate_required([
      :name
    ])
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
end
