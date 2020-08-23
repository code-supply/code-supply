defmodule SiteOperator.K8sAffiliateSite do
  @behaviour SiteOperator.AffiliateSite

  alias SiteOperator.K8s.{Certificate, Namespace}

  import SiteOperator.K8s.Operations

  @impl SiteOperator.AffiliateSite
  def create("", _) do
    {:error, "Empty name"}
  end

  @impl SiteOperator.AffiliateSite
  def create(_, []) do
    {:error, "No domains"}
  end

  @impl SiteOperator.AffiliateSite
  def create(name, domains) do
    if domains |> Enum.member?("") do
      {:error, "Empty domain"}
    else
      case execute(initial_creations(name, domains)) do
        {:ok, _} ->
          case execute(inner_ns_creations(name, domains)) do
            {:ok, _} ->
              {:ok, "Site created"}
          end

        {:error, _} = res ->
          res
      end
    end
  end

  @impl SiteOperator.AffiliateSite
  def delete(name) do
    execute(deletions(name))
  end

  @impl SiteOperator.AffiliateSite
  def reconcile(name, domains) do
    case execute(checks(name, domains)) do
      {:ok, _} ->
        {:ok, :nothing_to_do}

      {:error, some_resources_missing: missing_resources} ->
        Enum.each(missing_resources, fn resource ->
          {:ok, _} = recreate(resource, name, domains)
        end)

        {:ok, recreated: missing_resources}
    end
  end

  defp recreate(%Namespace{} = ns, name, domains) do
    case execute([create(ns)]) do
      {:ok, _} ->
        case execute(inner_ns_creations(name, domains)) do
          {:ok, _} ->
            {:ok, "Site created"}
        end

      {:error, _} = res ->
        res
    end
  end

  defp recreate(%Certificate{} = cert, _name, _domains) do
    execute([create(cert)])
  end

  defp execute(ops) do
    k8s().execute(ops)
  end

  defp k8s do
    Application.get_env(:site_operator, :k8s)
  end
end
