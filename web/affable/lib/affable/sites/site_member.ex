defmodule Affable.Sites.SiteMember do
  use Ecto.Schema
  import Ecto.Changeset

  alias Affable.Accounts.User
  alias Affable.Sites.Site

  schema "site_members" do
    belongs_to :user, User
    belongs_to :site, Site

    timestamps()
  end

  @doc false
  def changeset(site_member, attrs) do
    site_member
    |> cast(attrs, [])
    |> assoc_constraint(:user)
    |> assoc_constraint(:site)
  end
end
