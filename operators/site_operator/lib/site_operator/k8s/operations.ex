defmodule SiteOperator.K8s.Operations do
  import SiteOperator.K8s.Conversions, only: [to_k8s: 1]

  alias SiteOperator.PhoenixSites.PhoenixSite

  alias SiteOperator.K8s.{
    AffiliateSite,
    Deployment,
    Namespace,
    Operation,
    Secret,
    Service,
    VirtualService
  }

  import SiteOperator.K8s.Conversions

  def initial_creations(%PhoenixSite{name: name, domains: domains}) do
    initial_resources(name, domains)
    |> Enum.map(&create/1)
  end

  def inner_ns_creations(
        %PhoenixSite{
          name: namespace,
          secret_key_base: secret_key_base
        } = phoenix_site
      ) do
    name = "app"

    [
      deployment(phoenix_site),
      %Service{name: name, namespace: namespace},
      %Secret{
        name: name,
        namespace: namespace,
        data: %{
          "SECRET_KEY_BASE" => secret_key_base
        }
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

  def checks(%AffiliateSite{name: namespace, domains: domains} = affiliate_site) do
    (initial_resources(namespace, domains) ++
       [deployment(affiliate_site |> from_k8s())])
    |> Enum.map(&get/1)
  end

  def deletions(%AffiliateSite{name: name, domains: domains}) do
    initial_resources(name, domains)
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

  defp initial_resources(name, domains) do
    [
      %Namespace{
        name: name
      },
      %VirtualService{
        name: name,
        namespace: "affable",
        gateways: ["affable"],
        domains: domains
      }
    ]
  end
end
