defmodule Hosting.Domains do
  import Ecto.Query, warn: false
  alias Hosting.Repo

  alias Hosting.Domains.Domain
  alias Hosting.Sites.Site
  alias Hosting.Sites.SiteMember

  def by_name(name) do
    without_www = strip_prefix(name, "www")
    with_www = "www.#{without_www}"

    case Application.get_env(:hosting, HostingWeb.Endpoint)[:url][:host] do
      ^with_www ->
        %Domain{name: with_www, site: nil}

      _ ->
        Repo.one(
          from d in Domain,
            where: d.name == ^with_www or d.name == ^without_www
        )
    end
  end

  def hosting_suffix() do
    ".#{strip_prefix(Application.get_env(:hosting, HostingWeb.Endpoint)[:url][:host], "hosting")}"
  end

  def hosting_domain?(%Domain{name: name}) do
    String.ends_with?(name, hosting_suffix())
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

  def update_domain(%Domain{} = domain, attrs) do
    domain
    |> Domain.changeset(attrs)
    |> Repo.update()
  end

  def delete_domain!(user, domain_id) do
    hosting_name = "%#{hosting_suffix()}"

    from(d in Domain,
      join: sm in SiteMember,
      on: sm.site_id == d.site_id,
      where: sm.user_id == ^user.id,
      where: not like(d.name, ^hosting_name)
    )
    |> Repo.get_by!(id: domain_id)
    |> Repo.preload(:site)
    |> Repo.delete!()
  end

  def change_domain(%Domain{} = domain, attrs \\ %{}) do
    Domain.changeset(domain, attrs)
  end

  def k8s_certificate(cert_name, domain_name) do
    %{
      "apiVersion" => "cert-manager.io/v1",
      "kind" => "Certificate",
      "metadata" => %{
        "name" => cert_name,
        "namespace" => "hosting"
      },
      "spec" => %{
        "secretName" => "tls-#{cert_name}",
        "issuerRef" => %{
          "name" => "letsencrypt-production",
          "kind" => "ClusterIssuer"
        },
        "dnsNames" => [domain_name, www_flipped(domain_name)]
      }
    }
  end

  defp strip_prefix(s, prefix) do
    String.replace_leading(s, "#{prefix}.", "")
  end

  defp www_flipped("www." <> rest) do
    rest
  end

  defp www_flipped(domain) do
    "www." <> domain
  end
end