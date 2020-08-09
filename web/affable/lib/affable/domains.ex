defmodule Affable.Domains do
  @moduledoc """
  The Domains context.
  """

  import Ecto.Query, warn: false
  alias Affable.Repo

  alias Affable.Domains.Domain
  alias Affable.Events.Event

  @deployment_request "deployment-request"
  @undeployment_request "undeployment-request"

  def state(domain) do
    last_request =
      Repo.one(
        from(e in Event,
          where:
            e.event_type in [@deployment_request, @undeployment_request] and
              e.domain_id == ^domain.id,
          limit: 1,
          order_by: [desc: :id]
        )
      )

    case last_request do
      %Event{event_type: @deployment_request} ->
        :deploying

      _ ->
        :undeployed
    end
  end

  def deploy(user, domain_id, k8s) do
    domain = get_domain!(user, domain_id)

    record_event(domain_id, @deployment_request, "Deploying site")
    |> Repo.insert!()

    k8s.deploy(domain.name)
  end

  def undeploy(user, domain_id, k8s) do
    domain = get_domain!(user, domain_id)

    if state(domain) == :deploying do
      record_event(domain_id, @undeployment_request, "Undeploying site")
      |> Repo.insert!()

      k8s.undeploy(domain.name)
      {:ok, ""}
    else
      {:error, "Not yet deployed"}
    end
  end

  def list_domains(user) do
    Domain
    |> where(user_id: ^user.id)
    |> order_by(desc: :id)
    |> Repo.all()
    |> preload_events
  end

  def get_domain!(user, id) do
    Repo.get_by!(Domain, id: id, user_id: user.id)
    |> preload_events
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

  defp record_event(domain_id, type, description) do
    Event.changeset(%Event{}, %{
      event_type: type,
      domain_id: domain_id,
      description: description
    })
  end

  defp preload_events(query) do
    Repo.preload(query, events: from(e in Event, order_by: [desc: e.id]))
  end
end
