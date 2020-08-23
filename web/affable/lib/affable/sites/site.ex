defmodule Affable.Sites.Site do
  use Ecto.Schema
  import Ecto.Changeset

  alias Affable.Domains.Domain
  alias Affable.Sites.{Item, SiteMember}

  schema "sites" do
    field :name, :string
    field :internal_name, :string
    has_many :members, SiteMember
    has_many :users, through: [:members, :user]
    has_many :domains, Domain
    has_many :items, Item

    timestamps()
  end

  @doc false
  def changeset(site, attrs) do
    site
    |> cast(attrs, [:name])
    |> cast_assoc(:items, with: &Item.changeset/2)
    |> validate_required([:name])
  end

  def change_internal_name(site, internal_name) do
    site
    |> cast(%{internal_name: internal_name}, [:internal_name])
    |> validate_required([:internal_name])
  end
end
