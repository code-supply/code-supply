defmodule SiteOperator.K8s.Operations do
  import SiteOperator.K8sConversions, only: [to_k8s: 1]

  alias SiteOperator.K8s.{
    Certificate,
    Deployment,
    Gateway,
    Namespace,
    Operation,
    Secret,
    Service,
    VirtualService
  }

  def initial_creations(name, domains) do
    initial_resources(name, domains)
    |> Enum.map(&create/1)
  end

  def inner_ns_creations(name, namespace, domains, secret_key_base) do
    [
      %Deployment{name: name, namespace: namespace},
      %Service{name: name, namespace: namespace},
      %Gateway{name: name, domains: domains, namespace: namespace},
      %VirtualService{name: name, domains: domains, namespace: namespace},
      %Secret{name: name, namespace: namespace, data: %{"SECRET_KEY_BASE" => secret_key_base}}
    ]
    |> Enum.map(&create/1)
  end

  def checks(name, domains) do
    initial_resources(name, domains)
    |> Enum.map(&get/1)
  end

  def deletions(name) do
    initial_resources(name, [])
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
      %Namespace{name: name},
      %Certificate{name: name, domains: domains}
    ]
  end
end
