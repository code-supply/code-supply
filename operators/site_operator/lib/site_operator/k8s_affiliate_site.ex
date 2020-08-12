defmodule SiteOperator.K8sAffiliateSite do
  @behaviour SiteOperator.AffiliateSite

  alias SiteOperator.K8s.{Certificate, Namespace}

  import SiteOperator.K8s.Operations

  @impl SiteOperator.AffiliateSite
  def create("", _) do
    {:error, "Empty name"}
  end

  @impl SiteOperator.AffiliateSite
  def create(_, "") do
    {:error, "Empty domain"}
  end

  @impl SiteOperator.AffiliateSite
  def create(name, domain) do
    case execute(initial_creations(name, domain)) do
      {:ok, _} ->
        case execute(inner_ns_creations(name, domain)) do
          {:ok, _} ->
            {:ok, "Site created"}
        end

      {:error, _} = res ->
        res
    end
  end

  @impl SiteOperator.AffiliateSite
  def delete(name) do
    execute(deletions(name))
  end

  @impl SiteOperator.AffiliateSite
  def reconcile(name, domain) do
    case execute(checks(name, domain)) do
      {:ok, _} ->
        {:ok, :nothing_to_do}

      {:error, some_resources_missing: missing_resources} ->
        Enum.each(missing_resources, fn resource ->
          {:ok, _} = recreate(resource, name, domain)
        end)

        {:ok, recreated: missing_resources}
    end
  end

  defp recreate(%Namespace{} = ns, name, domain) do
    case execute([create(ns)]) do
      {:ok, _} ->
        case execute(inner_ns_creations(name, domain)) do
          {:ok, _} ->
            {:ok, "Site created"}
        end

      {:error, _} = res ->
        res
    end
  end

  defp recreate(%Certificate{} = cert, _name, _domain) do
    execute([create(cert)])
  end

  defp execute(ops) do
    k8s().execute(ops)
  end

  defp k8s do
    Application.get_env(:site_operator, :k8s)
  end
end
