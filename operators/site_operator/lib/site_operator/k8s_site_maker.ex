defmodule SiteOperator.K8sSiteMaker do
  @behaviour SiteOperator.SiteMaker

  alias SiteOperator.Domain
  alias SiteOperator.PhoenixSites.PhoenixSite

  alias SiteOperator.K8s.{
    AffiliateSite,
    Certificate,
    Deployment,
    Gateway,
    Ingress,
    Namespace,
    Operations,
    VirtualService
  }

  import SiteOperator.K8s.Conversions

  @hardcoded_ingress %Ingress{
    name: "load-balancer-affable",
    tls_secret_names: []
  }

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
    case proposed_site |> from_k8s() |> Operations.checks() |> execute() do
      {:ok, current_resources} ->
        case upgrade(proposed_site |> from_k8s(), current_resources) do
          {:ok, []} ->
            {:ok, :nothing_to_do}

          {:ok, upgraded_resources} ->
            {:ok, upgraded: upgraded_resources}

          {:error, msgs} ->
            {:error, upgrade_failed: msgs}
        end

      {:error, some_resources_missing: missing_resources} ->
        for resource <- missing_resources do
          {:ok, _} = recreate(resource, proposed_site)
        end

        {:ok, recreated: missing_resources}
    end
  end

  defp current_resources_to_upgraded_resources(current_resources, proposed_resources) do
    resource_types_to_check =
      Map.keys(current_resources)
      |> Enum.reduce([], fn rt, acc ->
        if proposed_resources |> Map.has_key?(rt) do
          [rt | acc]
        else
          acc
        end
      end)

    for resource_type <- resource_types_to_check do
      {current_resources[resource_type], proposed_resources[resource_type]}
    end
  end

  defp upgrade(
         %PhoenixSite{name: site_name, domains: domains} = proposed_phoenix_site,
         current_resources
       ) do
    basic_upgrade_result = upgrade_by_equality(proposed_phoenix_site, current_resources)

    with true <- Domain.any_custom?(domains),
         {:ok, upgraded_resources} <- basic_upgrade_result,
         {:ok, %{Ingress => [ingress]}} <- get_ingress(),
         true <- tls_secret_required?(ingress, site_name),
         upgraded_ingress <- Ingress.add_secret(ingress, site_name),
         {:ok, _} <- execute([Operations.update(upgraded_ingress)]) do
      {:ok, upgraded_resources ++ [upgraded_ingress]}
    else
      false -> basic_upgrade_result
      err -> err
    end
  end

  defp upgrade_by_equality(proposed_phoenix_site, current_resources) do
    current_resources_to_upgraded_resources(
      current_resources,
      Operations.upgradable_resources(proposed_phoenix_site)
    )
    |> Enum.reduce({:ok, []}, fn
      _, {:error, msg} ->
        {:error, msg}

      {[current], [current]}, {:ok, upgrades} ->
        {:ok, upgrades}

      {[current], [proposed]}, {:ok, upgrades} ->
        case execute([Operations.update(proposed)]) do
          {:ok, _} ->
            {:ok, [proposed | upgrades]}

          {:error, msgs} ->
            {:error,
             [
               original: current,
               proposed: proposed,
               proposed_phoenix_site: proposed_phoenix_site,
               messages: msgs
             ]}
        end
    end)
  end

  defp tls_secret_required?(%Ingress{tls_secret_names: names}, name) do
    Certificate.secret_name(name) not in names
  end

  defp get_ingress() do
    execute([Operations.get(@hardcoded_ingress)])
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
