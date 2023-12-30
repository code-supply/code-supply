defmodule Hosting.Sites.Site do
  use Ecto.Schema
  import Ecto.Changeset

  alias Hosting.Assets.Asset
  alias Hosting.Domains.Domain
  alias Hosting.Sites.{Page, SiteMember}

  schema "sites" do
    field(:name, :string)
    field(:internal_name, :string)
    field(:internal_hostname, :string)
    field(:made_available_at, :utc_datetime)
    field(:stylesheet, :string)

    has_many(:pages, Page)
    has_many(:assets, Asset)
    has_many(:members, SiteMember)
    has_many(:users, through: [:members, :user])
    has_many(:domains, Domain)

    timestamps()
  end

  @doc false
  def changeset(site, attrs) do
    site
    |> cast(
      attrs,
      [
        :name,
        :stylesheet
      ]
    )
    |> validate_required([
      :name
    ])
  end

  def change_internal_name(site, internal_name) do
    site
    |> cast(%{internal_name: internal_name, internal_hostname: "app.#{internal_name}"}, [
      :internal_name,
      :internal_hostname
    ])
    |> validate_required([:internal_name, :internal_hostname])
  end

  def change_made_available_at(site, time) do
    site
    |> cast(%{made_available_at: time}, [:made_available_at])
    |> validate_required([:made_available_at])
  end
end
