defmodule Affable.Sites.SiteMember do
  use Ecto.Schema
  import Ecto.Changeset

  schema "site_members" do
    field :user_id, :id
    field :site_id, :id

    timestamps()
  end

  @doc false
  def changeset(site_member, attrs) do
    site_member
    |> cast(attrs, [:user_id, :site_id])
    |> validate_required([:user_id, :site_id])
  end
end
