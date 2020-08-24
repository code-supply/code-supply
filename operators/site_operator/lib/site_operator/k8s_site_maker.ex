defmodule SiteOperator.K8sSiteMaker do
  @behaviour SiteOperator.SiteMaker

  alias SiteOperator.K8s.{Certificate, Namespace}

  import SiteOperator.K8s.Operations

  @impl SiteOperator.SiteMaker
  def create("", _, _) do
    {:error, "Empty name"}
  end

  @impl SiteOperator.SiteMaker
  def create(_, [], _) do
    {:error, "No domains"}
  end

  @impl SiteOperator.SiteMaker
  def create(site_name, domains, secret_key_base) do
    if domains |> Enum.member?("") do
      {:error, "Empty domain"}
    else
      case execute(initial_creations(prefixed(site_name), domains)) do
        {:ok, _} ->
          case execute_inner_ns_creations(site_name, domains, secret_key_base) do
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
    execute(deletions(prefixed(name)))
  end

  @impl SiteOperator.SiteMaker
  def reconcile(name, domains, secret_key_base) do
    case execute(checks(prefixed(name), domains)) do
      {:ok, _} ->
        {:ok, :nothing_to_do}

      {:error, some_resources_missing: missing_resources} ->
        Enum.each(missing_resources, fn resource ->
          {:ok, _} = recreate(resource, name, domains, secret_key_base)
        end)

        {:ok, recreated: missing_resources}
    end
  end

  defp recreate(%Namespace{} = ns, site_name, domains, secret_key_base) do
    case execute([create(ns)]) do
      {:ok, _} ->
        case execute_inner_ns_creations(site_name, domains, secret_key_base) do
          {:ok, _} ->
            {:ok, "Site created"}
        end

      {:error, _} = res ->
        res
    end
  end

  defp recreate(%Certificate{} = cert, _name, _domains, _secret_key_base) do
    execute([create(cert)])
  end

  defp execute_inner_ns_creations(site_name, domains, secret_key_base) do
    inner_ns_creations(
      "affiliate",
      prefixed(site_name),
      domains,
      secret_key_base
    )
    |> execute
  end

  defp execute(ops) do
    k8s().execute(ops)
  end

  defp prefixed(name) do
    "customer-#{name}"
  end

  defp k8s do
    Application.get_env(:site_operator, :k8s)
  end
end
