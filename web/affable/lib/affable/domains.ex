defmodule Affable.Domains do
  @moduledoc """
  The Domains context.
  """

  import Ecto.Query, warn: false
  alias Affable.Repo

  alias Affable.Domains.Domain
  alias Affable.Sites.Site

  def get_domain!(%Site{} = site, id) do
    Repo.get_by!(Domain, id: id, site_id: site.id)
  end

  def create_domain(%Site{} = site, attrs \\ %{}) do
    Ecto.build_assoc(site, :domains)
    |> Domain.changeset(attrs)
    |> Repo.insert()
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

  @doc """
  Deletes a domain.

  ## Examples

      iex> delete_domain(domain)
      {:ok, %Domain{}}

      iex> delete_domain(domain)
      {:error, %Ecto.Changeset{}}

  """
  def delete_domain(%Domain{} = domain) do
    Repo.delete(domain)
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
