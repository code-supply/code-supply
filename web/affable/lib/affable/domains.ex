defmodule Affable.Domains do
  @moduledoc """
  The Domains context.
  """

  import Ecto.Query, warn: false
  alias Affable.Repo

  alias Affable.Domains.Domain
  alias Affable.Events.Event

  def deploy!(user, domain_id, k8s) do
    domain = get_domain!(user, domain_id)

    Event.changeset(%Event{}, %{
      event_type: "deployment-request",
      domain_id: domain_id,
      description: "Deploying site"
    })
    |> Repo.insert!()

    k8s.deploy(domain.name)
  end

  def state(domain) do
    IO.inspect(Repo.all(Event))
    events = Repo.all(Ecto.assoc(domain, :events))

    case events do
      [] ->
        :new

      _ ->
        :deploying
    end
  end

  def list_domains(user) do
    Domain
    |> where(user_id: ^user.id)
    |> order_by(desc: :id)
    |> Repo.all()
    |> Repo.preload(:events)
  end

  def get_domain!(user, id) do
    Repo.get_by!(Domain, id: id, user_id: user.id)
    |> Repo.preload(:events)
  end

  def create_domain(user, attrs \\ %{}) do
    Ecto.build_assoc(user, :domains, %{events: []})
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
