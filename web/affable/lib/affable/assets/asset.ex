defmodule Affable.Assets.Asset do
  use Ecto.Schema
  import Ecto.Changeset

  alias Affable.Sites.Site

  schema "assets" do
    field :url, :string
    field :name, :string
    belongs_to :site, Site

    timestamps()
  end

  @doc false
  def changeset(asset, attrs) do
    asset
    |> cast(attrs, [:name, :site_id, :url])
    |> validate_required([:name])
  end
end
