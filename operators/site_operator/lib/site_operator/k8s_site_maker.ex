defmodule SiteOperator.K8sSiteMaker do
  @behaviour SiteOperator.SiteMaker

  alias SiteOperator.K8s.{AffiliateSite, Certificate, Namespace}

  alias SiteOperator.K8s.Operations

  @impl SiteOperator.SiteMaker
  def create(%AffiliateSite{name: ""}) do
    {:error, "Empty name"}
  end

  @impl SiteOperator.SiteMaker
  def create(%AffiliateSite{domains: []}) do
    {:error, "No domains"}
  end

  @impl SiteOperator.SiteMaker
  def create(%AffiliateSite{name: site_name, domains: domains} = site) do
    if "" in domains do
      {:error, "Empty domain"}
    else
      case execute(Operations.initial_creations(site_name, domains)) do
        {:ok, _} ->
          case site |> Operations.inner_ns_creations() |> execute() do
            {:ok, _} ->
              {:ok, "Site created"}
          end

        {:error, _} = res ->
          res
      end
    end
  end

  @impl SiteOperator.SiteMaker
  def delete(name) do
    execute(Operations.deletions(name))
  end

  @impl SiteOperator.SiteMaker
  def reconcile(%AffiliateSite{name: name, domains: domains} = site) do
    case execute(Operations.checks(name, domains)) do
      {:ok, _} ->
        {:ok, :nothing_to_do}

      {:error, some_resources_missing: missing_resources} ->
        Enum.each(missing_resources, fn resource ->
          {:ok, _} = recreate(resource, site)
        end)

        {:ok, recreated: missing_resources}
    end
  end

  defp recreate(%Namespace{} = ns, %AffiliateSite{} = site) do
    case execute([Operations.create(ns)]) do
      {:ok, _} ->
        case site |> Operations.inner_ns_creations() |> execute() do
          {:ok, _} ->
            {:ok, "Site created"}
        end

      {:error, _} = res ->
        res
    end
  end

  defp recreate(%Certificate{} = cert, _) do
    execute([Operations.create(cert)])
  end

  defp execute(ops) do
    k8s().execute(ops)
  end

  defp k8s do
    Application.get_env(:site_operator, :k8s)
  end
end
