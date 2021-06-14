defmodule SiteOperator.K8s.Operations do
  import SiteOperator.K8s.Conversions, only: [to_k8s: 1]

  alias SiteOperator.Domain
  alias SiteOperator.PhoenixSites.PhoenixSite

  alias SiteOperator.K8s.{
    AuthorizationPolicy,
    Certificate,
    Deployment,
    Gateway,
    Namespace,
    Operation,
    Secret,
    Service,
    VirtualService
  }

  import SiteOperator.K8s.Conversions

  def creations(phoenix_site) do
    [initial_creations(phoenix_site), inner_ns_creations(phoenix_site)]
  end

  def initial_creations(%PhoenixSite{} = site) do
    initial_resources(site)
    |> Enum.map(&create/1)
  end

  def inner_ns_creations(
        %PhoenixSite{
          name: namespace,
          secret_key_base: secret_key_base,
          live_view_signing_salt: live_view_signing_salt
        } = phoenix_site
      ) do
    name = "app"

    [
      deployment(phoenix_site),
      %Service{name: name, namespace: namespace},
      virtual_service(phoenix_site),
      %Secret{
        name: name,
        namespace: namespace,
        data: %{
          "SECRET_KEY_BASE" => secret_key_base,
          "LIVE_VIEW_SIGNING_SALT" => live_view_signing_salt
        }
      },
      %AuthorizationPolicy{
        name: name,
        namespace: namespace,
        allow_all_with_methods: ["GET", "HEAD", "OPTIONS"],
        allow_all_from_namespaces: ["affable"]
      }
    ]
    |> Enum.map(&create/1)
  end

  def upgradable_resources(phoenix_site) do
    %{
      Certificate => certificates(phoenix_site),
      Deployment => [deployment(phoenix_site)],
      Gateway => site_gateways(phoenix_site),
      VirtualService => [virtual_service(phoenix_site)]
    }
  end

  def namespace(%PhoenixSite{name: name}) do
    %Namespace{name: name}
  end

  def deployment(%PhoenixSite{
        name: namespace,
        image: image,
        domains: domains
      }) do
    %Deployment{
      name: "app",
      namespace: namespace,
      image: image,
      env_vars: %{
        "CHECK_ORIGINS" =>
          domains
          |> Enum.map(fn domain -> "https://#{domain}" end)
          |> Enum.join(" "),
        "PREVIEW_URL" => "http://affable.affable/api/sites/#{namespace}/preview",
        "PUBLISHED_URL" => "http://affable.affable/api/sites/#{namespace}",
        "TLS_REDIRECT_EXCLUDE_HOST" => internal_hostname_from_domains(domains),
        "URL_HOST" => url_host_from_domains(domains)
      }
    }
  end

  defp url_host_from_domains([domain]) do
    domain
  end

  defp url_host_from_domains(domains) do
    Enum.find(domains, &(!Domain.is_affable?(&1)))
  end

  defp internal_hostname_from_domains(domains) do
    case Enum.find(domains, &Domain.is_affable?(&1)) do
      nil -> "could-not-find-affable-domain"
      domain -> Domain.internal_hostname(domain)
    end
  end

  def virtual_service(%PhoenixSite{name: namespace, domains: domains}) do
    %VirtualService{
      name: "app",
      namespace: namespace,
      gateways: ["affable/affable"] ++ Enum.map(site_gateways(namespace, domains), & &1.name),
      domains: domains
    }
  end

  def checks(%PhoenixSite{name: namespace, domains: domains} = site) do
    (initial_resources(site) ++
       certificates(site) ++
       site_gateways(namespace, domains) ++
       [virtual_service(site)] ++
       [deployment(site)])
    |> Enum.map(&get/1)
  end

  defp certificates(%PhoenixSite{name: name, domains: all_domains}) do
    case custom_domains(all_domains) do
      [] -> []
      domains -> [%Certificate{name: name, domains: domains}]
    end
  end

  defp site_gateways(%PhoenixSite{name: name, domains: domains}) do
    site_gateways(name, domains)
  end

  defp site_gateways(name, all_domains) do
    case custom_domains(all_domains) do
      [] -> []
      domains -> [%Gateway{name: "app", namespace: name, domains: domains}]
    end
  end

  defp custom_domains(domains) do
    Enum.reject(domains, &Domain.is_affable?/1)
  end

  defp initial_resources(%PhoenixSite{} = site) do
    [namespace(site)]
  end

  def deletions(%PhoenixSite{} = site) do
    (initial_resources(site) ++ certificates(site))
    |> Enum.map(&delete/1)
  end

  def get(resource) do
    %Operation{action: :get, resource: resource |> to_k8s()}
  end

  def create(resource) do
    %Operation{action: :create, resource: resource |> to_k8s()}
  end

  def delete(resource) do
    %Operation{action: :delete, resource: resource |> to_k8s()}
  end

  def update(resource) do
    %Operation{action: :update, resource: resource |> to_k8s()}
  end
end
