defmodule Hosting.Assets.Asset do
  use Ecto.Schema
  import Ecto.Changeset

  alias Hosting.Sites.Site

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
    |> validate_format(:url, ~r|gs://[a-z0-9-]+/.+|, message: "must choose a file")
  end
end
