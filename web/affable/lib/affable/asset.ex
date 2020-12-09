defmodule Affable.Asset do
  use Ecto.Schema
  import Ecto.Changeset

  schema "assets" do
    field :url, :string
    field :site_id, :id

    timestamps()
  end

  @doc false
  def changeset(asset, attrs) do
    asset
    |> cast(attrs, [:url])
    |> validate_required([:url])
  end
end
