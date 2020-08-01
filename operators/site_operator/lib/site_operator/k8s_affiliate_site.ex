defmodule SiteOperator.K8sAffiliateSite do
  @behaviour SiteOperator.AffiliateSite
  import SiteOperator.K8sFactories

  @impl SiteOperator.AffiliateSite
  def create(namespace_name) do
    namespace_operation = K8s.Client.create(ns(namespace_name))
    deployment_operation = K8s.Client.create(deployment(namespace_name))

    {:ok, _} = run(namespace_operation)
    {:ok, _} = run(deployment_operation)

    {:ok, ""}
  end

  @impl SiteOperator.AffiliateSite
  def delete(namespace_name) do
    operation = K8s.Client.delete("v1", "Namespace", name: namespace_name)
    run(operation)
  end

  defp run(operation) do
    K8s.Client.run(operation, cluster_name())
  end

  defp cluster_name do
    Application.get_env(:bonny, :cluster_name)
  end
end
