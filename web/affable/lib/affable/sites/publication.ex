defmodule Affable.Sites.Publication do
  use Ecto.Schema
  import Ecto.Changeset

  schema "publications" do
    field :data, :map
    field :site_id, :id

    timestamps()
  end

  @doc false
  def changeset(publication, attrs) do
    publication
    |> cast(attrs, [:data])
    |> validate_required([:data])
  end
end
