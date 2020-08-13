defmodule Affable.Sites do
  import Ecto.Query, warn: false
  alias Affable.Repo
  alias Affable.Accounts.User
  alias Affable.Sites.Site

  alias Ecto.Multi

  def get_site!(id) do
    Repo.get!(Site, id)
    |> Repo.preload([:domains, :members])
  end

  def create_site(%User{} = user, attrs \\ %{}) do
    case Multi.new()
         |> Multi.insert(
           :site,
           %Site{}
           |> Site.changeset(attrs)
           |> Ecto.Changeset.put_assoc(:members, [Ecto.build_assoc(user, :site_members)])
         )
         |> Multi.insert(
           :domain,
           fn %{site: site} ->
             Ecto.build_assoc(site, :domains, %{name: generate_domain_name(site.id)})
           end
         )
         |> Repo.transaction() do
      {:ok, %{site: site}} ->
        {:ok, site |> Repo.preload(:domains)}

      {:error, :site, site, %{} = _domain} ->
        {:error, site}
    end
  end

  def update_site(%Site{} = site, attrs) do
    site
    |> Site.changeset(attrs)
    |> Repo.update()
  end

  def delete_site(%Site{} = site) do
    Repo.delete(site)
  end

  def change_site(%Site{} = site, attrs \\ %{}) do
    Site.changeset(site, attrs)
  end

  def generate_domain_name(number) do
    "site#{Affable.ID.encode(number)}.affable.app"
  end
end
