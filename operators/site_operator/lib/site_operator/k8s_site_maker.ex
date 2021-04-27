defmodule SiteOperator.K8sSiteMaker do
  @behaviour SiteOperator.SiteMaker

  alias SiteOperator.PhoenixSites.PhoenixSite

  alias SiteOperator.K8s.{
    AffiliateSite,
    Certificate,
    Deployment,
    Gateway,
    Namespace,
    Operations,
    VirtualService
  }

  import SiteOperator.K8s.Conversions

  @impl SiteOperator.SiteMaker
  def create(%AffiliateSite{} = site) do
    site
    |> from_k8s
    |> Operations.creations()
    |> Enum.find_value({:ok, "Site created"}, fn batch ->
      case execute(batch) do
        {:ok, _} -> false
        failure -> failure
      end
    end)
  end

  @impl SiteOperator.SiteMaker
  def delete(%AffiliateSite{} = site) do
    execute(Operations.deletions(site |> from_k8s()))
  end

  @impl SiteOperator.SiteMaker
  def reconcile(%AffiliateSite{} = proposed_site) do
    case proposed_site |> Operations.checks() |> execute() do
      {:ok, current_resources} ->
        upgraded_resources = upgrade(proposed_site |> from_k8s(), current_resources)

        if upgraded_resources |> length == 0 do
          {:ok, :nothing_to_do}
        else
          {:ok, upgraded: upgraded_resources}
        end

      {:error, some_resources_missing: missing_resources} ->
        for resource <- missing_resources do
          {:ok, _} = recreate(resource, proposed_site)
        end

        {:ok, recreated: missing_resources}
    end
  end

  defp upgrade(%PhoenixSite{} = proposed_phoenix_site, %{
         Deployment => [current_deployment],
         VirtualService => [current_virtual_service]
       }) do
    [
      {current_deployment, proposed_phoenix_site |> Operations.deployment()},
      {current_virtual_service, proposed_phoenix_site |> Operations.virtual_service()}
    ]
    |> Enum.reduce([], fn
      {current, current}, upgrades ->
        upgrades

      {_current, proposed}, upgrades ->
        {:ok, _} = execute([Operations.update(proposed)])
        [proposed | upgrades]
    end)
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

  defp recreate(%Gateway{} = gateway, _) do
    execute([Operations.create(gateway)])
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
