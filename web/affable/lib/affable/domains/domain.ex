defmodule Affable.Domains.Domain do
  use Ecto.Schema
  import Ecto.Changeset

  alias Affable.Sites.Site

  schema "domains" do
    field :name, :string
    belongs_to :site, Site

    timestamps()
  end

  @doc false
  def changeset(domain, attrs) do
    domain
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_format(:name, ~r/^[^.].*$/, message: "cannot begin with a dot")
    |> validate_format(:name, ~r/^[^ ]+$/, message: "domains don't have spaces")
    |> validate_domain()
    |> unique_constraint(:name)
  end

  defp validate_domain(%Ecto.Changeset{changes: %{name: name}} = changeset) do
    case URI.parse("//#{name}") do
      %URI{
        fragment: nil,
        path: nil,
        port: nil,
        scheme: nil,
        query: nil,
        userinfo: nil
      } ->
        changeset

      %URI{} ->
        changeset
        |> add_error(:name, "must be a valid domain")
    end
  end

  defp validate_domain(changeset_without_name_change) do
    changeset_without_name_change
  end
end
