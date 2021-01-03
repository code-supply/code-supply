defmodule Affable.Assets.Asset do
  use Ecto.Schema
  import Ecto.Changeset

  schema "assets" do
    field :url, :string
    field :name, :string
    field :site_id, :id

    timestamps()
  end

  @doc false
  def changeset(asset, attrs) do
    asset
    |> cast(attrs, [:name, :site_id])
    |> validate_required([:name])
  end
end
