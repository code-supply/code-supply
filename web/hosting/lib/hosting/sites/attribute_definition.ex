defmodule Hosting.Sites.AttributeDefinition do
  use Ecto.Schema
  import Ecto.Changeset

  alias Hosting.Sites.Site

  schema "attribute_definitions" do
    field :name, :string
    field :type, :string
    belongs_to :site, Site

    timestamps()
  end

  @doc false
  def changeset(attribute_definition, attrs) do
    attribute_definition
    |> cast(attrs, [:name, :type])
    |> validate_required([:name, :type])
    |> validate_inclusion(:type, ["dollar", "pound", "euro", "number", "text"])
  end
end
