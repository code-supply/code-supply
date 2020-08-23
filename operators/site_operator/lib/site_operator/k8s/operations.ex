defmodule SiteOperator.K8s.Operations do
  import SiteOperator.K8sConversions, only: [to_k8s: 1]

  alias SiteOperator.K8s.{
    Certificate,
    Deployment,
    Gateway,
    Namespace,
    Operation,
    Service,
    VirtualService
  }

  def initial_creations(name, domains) do
    initial_resources(name, domains)
    |> Enum.map(&create/1)
  end

  def inner_ns_creations(name, domains) do
    [
      %Deployment{name: name},
      %Service{name: name},
      %Gateway{name: name, domains: domains},
      %VirtualService{name: name, domains: domains}
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
