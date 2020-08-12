defmodule SiteOperator.K8sAffiliateSite do
  @behaviour SiteOperator.AffiliateSite

  alias SiteOperator.K8s.Namespace

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
    case execute([create(%Namespace{name: name})]) do
      {:ok, _} ->
        case execute(create_operations(name, domain)) do
          {:ok, _} ->
            {:ok, "Site created"}
        end

      {:error, _} = res ->
        res
    end
  end

  @impl SiteOperator.AffiliateSite
  def delete(name) do
    execute(delete_operations(name))
  end

  @impl SiteOperator.AffiliateSite
  def reconcile(name, domain) do
    case execute(check_operations(name, domain)) do
      {:ok, _} ->
        {:ok, :nothing_to_do}

      {:error, some_resources_missing: missing_resources} ->
        execute(Enum.map(missing_resources, &create/1))
        {:ok, recreated: missing_resources}
    end
  end

  defp execute(ops) do
    k8s().execute(ops)
  end

  defp k8s do
    Application.get_env(:site_operator, :k8s)
  end
end
