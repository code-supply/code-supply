defmodule SiteOperator.K8sAffiliateSite do
  @behaviour SiteOperator.AffiliateSite
  import SiteOperator.K8sFactories

  @impl SiteOperator.AffiliateSite
  def create(name) do
    namespace_operation = K8s.Client.create(ns(name))
    deployment_operation = K8s.Client.create(deployment(name))
    service_operation = K8s.Client.create(service(name))

    {:ok, _} = run(namespace_operation)
    {:ok, _} = run(deployment_operation)
    {:ok, _} = run(service_operation)

    {:ok, ""}
  end

  @impl SiteOperator.AffiliateSite
  def delete(name) do
    operation = K8s.Client.delete("v1", "Namespace", name: name)
    run(operation)
  end

  defp run(operation) do
    K8s.Client.run(operation, cluster_name())
  end

  defp cluster_name do
    Application.get_env(:bonny, :cluster_name)
  end
end
