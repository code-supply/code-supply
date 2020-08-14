defmodule Affable.Sites.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :description, :string
    field :image_url, :string
    field :name, :string
    field :position, :integer
    field :price, :decimal
    field :url, :string
    field :site_id, :id

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :description, :url, :image_url, :price, :position])
    |> validate_required([:name, :description, :url, :image_url, :price, :position])
  end
end
