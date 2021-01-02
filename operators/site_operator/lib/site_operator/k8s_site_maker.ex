defmodule SiteOperator.K8sSiteMaker do
  @behaviour SiteOperator.SiteMaker

  alias SiteOperator.K8s.{
    AffiliateSite,
    Certificate,
    Deployment,
    Namespace,
    Operations,
    VirtualService
  }

  import SiteOperator.K8s.Conversions

  @impl SiteOperator.SiteMaker
  def create([batch | batches]) do
    case execute(batch) do
      {:ok, _} ->
        create(batches)

      {:error, _} = res ->
        res
    end
  end

  @impl SiteOperator.SiteMaker
  def create([]) do
    {:ok, "Site created"}
  end

  @impl SiteOperator.SiteMaker
  def delete(%AffiliateSite{} = site) do
    execute(Operations.deletions(site))
  end

  @impl SiteOperator.SiteMaker
  def reconcile(%AffiliateSite{} = site) do
    case site |> Operations.checks() |> execute() do
      {:ok, [_, _, current_deployment]} ->
        proposed_deployment = site |> from_k8s() |> Operations.deployment()

        if current_deployment != proposed_deployment do
          {:ok, _} = execute([Operations.update(proposed_deployment)])
          {:ok, upgraded: [proposed_deployment]}
        else
          {:ok, :nothing_to_do}
        end

      {:error, some_resources_missing: missing_resources} ->
        for resource <- missing_resources do
          {:ok, _} = recreate(resource, site)
        end

        {:ok, recreated: missing_resources}
    end
  end

  defp recreate(%Namespace{} = ns, %AffiliateSite{} = site) do
    case execute([Operations.create(ns)]) do
      {:ok, _} ->
        case site |> from_k8s() |> Operations.inner_ns_creations() |> execute() do
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

  defp recreate(%VirtualService{} = vs, _) do
    execute([Operations.create(vs)])
  end

  defp recreate(%Deployment{}, _) do
    {:ok, "Refusing to do anything until we decide we need to"}
  end

  defp execute(ops) do
    k8s().execute(ops)
  end

  defp k8s do
    Application.get_env(:site_operator, :k8s)
  end
end
