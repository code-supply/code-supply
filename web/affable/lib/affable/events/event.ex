defmodule Affable.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias Affable.Accounts.User
  alias Affable.Domains.Domain

  schema "events" do
    field :description, :string
    field :event_type, :string
    belongs_to :user, User
    belongs_to :domain, Domain

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:description, :user_id, :domain_id, :event_type])
    |> validate_required([:description])
  end
end
