defmodule Affable.Domains do
  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias Affable.Repo
  alias Affable.Domains.Domain
  alias Affable.Sites.Site
  alias Affable.Sites.SiteMember

  def affable_suffix() do
    ".affable.app"
  end

  def affable_domain?(%Domain{name: name}) do
    String.ends_with?(name, affable_suffix())
  end

  def list_insert(domains, %Domain{site_id: new_site_id} = new) do
    List.insert_at(
      domains,
      find_index_with_site_id(domains, new_site_id),
      new
    )
  end

  defp find_index_with_site_id(domains, site_id) do
    Enum.find_index(domains, &(&1.site_id == site_id))
  end

  def get_domain!(%Site{} = site, id) do
    Repo.get_by!(Domain, id: id, site_id: site.id)
    |> preloads()
  end

  def create_domain(%Site{} = site, attrs \\ %{}) do
    case Multi.new()
         |> Multi.update(:assign_lb, Site.change_load_balancer(site, load_balancer_for(site)))
         |> Multi.insert(:create_domain, fn %{assign_lb: lb_site} ->
           Ecto.build_assoc(lb_site, :domains)
           |> Domain.changeset(attrs)
         end)
         |> Repo.transaction() do
      {:ok, %{create_domain: domain}} ->
        {:ok, preloads(domain)}
    end
  end

  defp load_balancer_for(site) do
    groups = Repo.all(Site) |> Enum.group_by(fn s -> s.load_balancer_index end)

    case Enum.find(groups, fn
           {idx, sites} ->
             case(idx) do
               nil ->
                 false

               0 ->
                 length(sites) < certificates_per_load_balancer() - 1

               _ ->
                 length(sites) < certificates_per_load_balancer()
             end
         end) do
      nil ->
        case Map.keys(groups) do
          [nil | [n | counts]] ->
            Enum.max([n | counts]) + 1

          _ ->
            0
        end

      {lb_idx, _} ->
        lb_idx |> IO.inspect()
    end
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

  def update_domain(%Domain{} = domain, attrs) do
    domain
    |> Domain.changeset(attrs)
    |> Repo.update()
  end

  def delete_domain!(user, domain_id) do
    affable_name = "%#{affable_suffix()}"

    from(d in Domain,
      join: sm in SiteMember,
      on: sm.site_id == d.site_id,
      where: sm.user_id == ^user.id,
      where: not like(d.name, ^affable_name)
    )
    |> Repo.get_by!(id: domain_id)
    |> Repo.delete!()
  end

  def change_domain(%Domain{} = domain, attrs \\ %{}) do
    Domain.changeset(domain, attrs)
  end

  defp certificates_per_load_balancer() do
    Application.get_env(:affable, :certificates_per_load_balancer)
  end
end
