defmodule Affable.Sites.AttributeDefinition do
  use Ecto.Schema
  import Ecto.Changeset

  schema "attribute_definitions" do
    field :name, :string
    field :type, :string
    field :site_id, :id

    timestamps()
  end

  @doc false
  def changeset(attribute_definition, attrs) do
    attribute_definition
    |> cast(attrs, [:name, :type])
    |> validate_required([:name, :type])
  end
end
