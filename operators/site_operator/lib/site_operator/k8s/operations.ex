defmodule SiteOperator.K8s.Operations do
  import SiteOperator.K8s.Conversions, only: [to_k8s: 1]

  alias SiteOperator.PhoenixSites.PhoenixSite

  alias SiteOperator.K8s.{
    AffiliateSite,
    Deployment,
    Namespace,
    Operation,
    RoleBinding,
    Secret,
    Service,
    VirtualService
  }

  def initial_creations(%PhoenixSite{name: name, domains: domains}) do
    initial_resources(name, domains)
    |> Enum.map(&create/1)
  end

  def inner_ns_creations(%PhoenixSite{
        name: namespace,
        image: image,
        domains: domains,
        secret_key_base: secret_key_base,
        distribution_cookie: distribution_cookie
      }) do
    name = "affiliate"

    [
      %Deployment{
        name: name,
        namespace: namespace,
        image: image,
        env_vars: %{
          "CHECK_ORIGINS" =>
            domains
            |> Enum.map(fn domain -> "https://#{domain}" end)
            |> Enum.join(" "),
          "PUBSUB_TOPIC_INCOMING" => namespace,
          "PUBSUB_TOPIC_REQUESTS" => Application.get_env(:site_operator, :pubsub_topic_requests),
          "ELIXIR_ERL_OPTIONS" => "-kernel inet_dist_listen_min 5555 inet_dist_listen_max 5555",
          "RELEASE_DISTRIBUTION" => "name",
          "RELEASE_NODE" => "affable@$(POD_IP)"
        }
      },
      %Service{name: name, namespace: namespace},
      %Secret{
        name: name,
        namespace: namespace,
        data: %{
          "SECRET_KEY_BASE" => secret_key_base,
          "RELEASE_COOKIE" => distribution_cookie
        }
      }
    ]
    |> Enum.map(&create/1)
  end

  def checks(%AffiliateSite{name: name, domains: domains}) do
    initial_resources(name, domains)
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

  defp initial_resources(name, domains) do
    [
      %Namespace{
        name: name
      },
      %RoleBinding{
        name: "endpoint-listing-for-#{name}",
        namespace: "affable",
        role_kind: "ClusterRole",
        role_name: "endpoint-lister",
        subjects: [%{kind: "ServiceAccount", name: "default", namespace: name}]
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
