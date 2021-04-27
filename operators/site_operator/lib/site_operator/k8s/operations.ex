defmodule SiteOperator.K8s.Operations do
  import SiteOperator.K8s.Conversions, only: [to_k8s: 1]

  alias SiteOperator.Domain
  alias SiteOperator.PhoenixSites.PhoenixSite

  alias SiteOperator.K8s.{
    AffiliateSite,
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

  def initial_creations(%PhoenixSite{name: name}) do
    initial_resources(name)
    |> Enum.map(&create/1)
  end

  def inner_ns_creations(
        %PhoenixSite{
          name: namespace,
          domains: domains,
          secret_key_base: secret_key_base,
          live_view_signing_salt: live_view_signing_salt
        } = phoenix_site
      ) do
    name = "app"

    [
      deployment(phoenix_site),
      %Service{name: name, namespace: namespace},
      %VirtualService{
        name: "app",
        namespace: namespace,
        gateways: ["affable/affable"],
        domains: domains
      },
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
        "PUBLISHED_URL" => "http://affable.affable/api/sites/#{namespace}"
      }
    }
  end

  def virtual_service(%PhoenixSite{name: namespace, domains: domains}) do
    %VirtualService{
      name: "app",
      namespace: namespace,
      gateways: [],
      domains: domains
    }
  end

  def checks(%AffiliateSite{name: namespace, domains: domains} = affiliate_site) do
    (initial_resources(namespace) ++
       certificates(namespace, domains) ++
       gateways(namespace, domains) ++
       virtual_services(namespace, domains) ++
       [deployment(affiliate_site |> from_k8s())])
    |> Enum.map(&get/1)
  end

  defp certificates(name, all_domains) do
    case custom_domains(all_domains) do
      [] -> []
      domains -> [%Certificate{name: name, domains: domains}]
    end
  end

  defp virtual_services(namespace, all_domains) do
    [
      %VirtualService{
        name: "app",
        namespace: namespace,
        gateways: ["affable/affable"],
        domains: all_domains
      }
    ]
  end

  defp gateways(name, all_domains) do
    case custom_domains(all_domains) do
      [] -> []
      domains -> [%Gateway{name: "app", namespace: name, domains: domains}]
    end
  end

  defp custom_domains(domains) do
    Enum.reject(domains, &Domain.is_affable?/1)
  end

  defp initial_resources(name) do
    [
      %Namespace{
        name: name
      }
    ]
  end

  def deletions(%PhoenixSite{name: name, domains: domains}) do
    (initial_resources(name) ++ certificates(name, domains))
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
