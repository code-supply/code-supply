defmodule Affable.Affable.Sites.Attribute do
  use Ecto.Schema
  import Ecto.Changeset

  schema "attributes" do
    field :value, :string
    field :item_id, :id
    field :definition_id, :id

    timestamps()
  end

  @doc false
  def changeset(attribute, attrs) do
    attribute
    |> cast(attrs, [:value])
    |> validate_required([:value])
  end
end
