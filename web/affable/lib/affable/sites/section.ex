defmodule Affable.Sites.Section do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :name, :string
  end
end
