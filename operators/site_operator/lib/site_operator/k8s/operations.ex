defmodule SiteOperator.K8s.Operations do
  import SiteOperator.K8sFactories, only: [to_k8s: 1]

  alias SiteOperator.K8s.{
    Certificate,
    Deployment,
    Gateway,
    Namespace,
    Operation,
    Service,
    VirtualService
  }

  def create_operations(name, domain) do
    [
      %Deployment{name: name},
      %Service{name: name},
      %Gateway{name: name, domains: [domain]},
      %VirtualService{name: name, domains: [domain]},
      %Certificate{name: name, domains: [domain]}
    ]
    |> Enum.map(&create/1)
  end

  def check_operations(name, domain) do
    [
      %Namespace{name: name},
      %Certificate{name: name, domains: [domain]}
    ]
    |> Enum.map(&get/1)
  end

  def delete_operations(name) do
    [
      %Namespace{name: name},
      %Certificate{name: name, domains: []}
    ]
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
end
