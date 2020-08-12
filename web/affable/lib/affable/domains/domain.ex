defmodule Affable.Domains.Domain do
  use Ecto.Schema
  import Ecto.Changeset

  alias Affable.Accounts.User
  alias Affable.Events.Event
  alias Affable.Sites.Site

  schema "domains" do
    field :name, :string
    belongs_to :user, User
    belongs_to :site, Site
    has_many :events, Event

    timestamps()
  end

  @doc false
  def changeset(domain, attrs) do
    domain
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
    |> validate_format(
      :name,
      ~r/^((?!-))(xn--)?[a-z0-9][a-z0-9-_]{0,61}[a-z0-9]{0,1}\.(xn--)?([a-z0-9\-]{1,61}|[a-z0-9-]{1,30}\.[a-z]{2,})$/,
      message: "must be a valid domain"
    )
  end
end
