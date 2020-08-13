defmodule Affable.Sites.Site do
  use Ecto.Schema
  import Ecto.Changeset

  alias Affable.Domains.Domain
  alias Affable.Sites.SiteMember

  schema "sites" do
    field :name, :string
    has_many :members, SiteMember
    has_many :users, through: [:members, :user]
    has_many :domains, Domain

    timestamps()
  end

  @doc false
  def changeset(site, attrs) do
    site
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
