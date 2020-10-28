defmodule Affable.Sites.Item do
  use Ecto.Schema
  import Ecto.Changeset

  alias Affable.Sites.Attribute

  schema "items" do
    field :description, :string
    field :image_url, :string
    field :name, :string
    field :position, :integer
    field :url, :string
    field :site_id, :id
    has_many :attributes, Attribute

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :description, :url, :image_url, :position])
    |> cast_assoc(:attributes, with: &Attribute.changeset/2)
    |> validate_required([:name, :position])
  end
end
