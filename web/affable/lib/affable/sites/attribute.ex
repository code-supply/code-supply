defmodule Affable.Sites.Attribute do
  use Ecto.Schema
  import Ecto.Changeset

  alias Affable.Sites.{AttributeDefinition, Item}

  schema "attributes" do
    field :value, :string
    belongs_to :item, Item
    belongs_to :definition, AttributeDefinition

    timestamps()
  end

  @doc false
  def changeset(attribute, attrs) do
    attribute
    |> cast(attrs, [:value])
  end
end
