defmodule Affable.Domains.Domain do
  use Ecto.Schema
  import Ecto.Changeset

  alias Affable.Accounts.User

  schema "domains" do
    field :name, :string
    belongs_to(:user, User)

    timestamps()
  end

  @doc false
  def changeset(domain, attrs) do
    domain
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
  end
end
