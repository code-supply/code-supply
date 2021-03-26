defmodule Affable.Domains do
  @moduledoc """
  The Domains context.
  """

  import Ecto.Query, warn: false
  alias Affable.Repo

  alias Affable.Domains.Domain
  alias Affable.Sites.Site
  alias Affable.Sites.SiteMember

  def get_domain!(%Site{} = site, id) do
    Repo.get_by!(Domain, id: id, site_id: site.id)
    |> preloads()
  end

  def create_domain(%Site{} = site, attrs \\ %{}) do
    Ecto.build_assoc(site, :domains)
    |> Domain.changeset(attrs)
    |> Repo.insert()
    |> preloads()
  end

  defp preloads({:ok, domain}) do
    {:ok, preloads(domain)}
  end

  defp preloads(%Domain{} = domain) do
    domain |> Repo.preload(:site)
  end

  defp preloads(otherwise) do
    otherwise
  end

  @doc """
  Updates a domain.

  ## Examples

      iex> update_domain(domain, %{field: new_value})
      {:ok, %Domain{}}

      iex> update_domain(domain, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_domain(%Domain{} = domain, attrs) do
    domain
    |> Domain.changeset(attrs)
    |> Repo.update()
  end

  def delete_domain!(user, domain_id) do
    domain =
      Repo.get_by!(
        from(d in Domain,
          join: sm in SiteMember,
          on: sm.site_id == d.site_id,
          where: sm.user_id == ^user.id
        ),
        id: domain_id
      )

    {domain_id, ""} = Integer.parse(domain_id)
    Repo.delete!(%Domain{id: domain_id})
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking domain changes.

  ## Examples

      iex> change_domain(domain)
      %Ecto.Changeset{data: %Domain{}}

  """
  def change_domain(%Domain{} = domain, attrs \\ %{}) do
    Domain.changeset(domain, attrs)
  end
end
