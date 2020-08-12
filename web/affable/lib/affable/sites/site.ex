defmodule Affable.Sites.Site do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sites" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(site, attrs) do
    site
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
