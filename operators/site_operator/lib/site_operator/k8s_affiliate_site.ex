defmodule SiteOperator.K8sAffiliateSite do
  @behaviour SiteOperator.AffiliateSite
  import SiteOperator.K8sFactories

  alias K8s.Client

  alias SiteOperator.K8s.{
    Certificate,
    Deployment,
    Gateway,
    Namespace,
    Service,
    VirtualService
  }

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
    case create_ns(name) do
      {:ok, _} ->
        case Client.parallel(create_operations(name, domain), cluster_name(), []) do
          [ok: _, ok: _, ok: _, ok: _, ok: _] ->
            {:ok, "Site created"}

          [{_, _}, {_, _}, {:error, %HTTPoison.Response{body: gateway_error_body}} | _] ->
            {:error, "Failed to create gateway: #{gateway_error_body}"}
        end

      {:error, %{body: ns_error_body}} ->
        {:error, ns_error_body}
    end
  end

  @impl SiteOperator.AffiliateSite
  def delete(name) do
    case Client.parallel(delete_operations(name), cluster_name(), []) do
      [ok: _, ok: _] ->
        {:ok, "Deleted #{name}"}

      [error: :not_found, error: :not_found] ->
        {:error, "Dependents no longer exist."}

      [error: :not_found, ok: _] ->
        {:ok, "Namespace already gone, deleted certificate anyway."}

      [ok: _, error: :not_found] ->
        {:ok, "Certificate already gone, deleted namespace anyway."}
    end
  end

  defp create_operations(name, domain) do
    [
      %Deployment{name: name},
      %Service{name: name},
      %Gateway{name: name, domain: domain},
      %VirtualService{name: name, domain: domain},
      %Certificate{name: name, domains: [domain]}
    ]
    |> Enum.map(&to_k8s/1)
    |> Enum.map(&Client.create/1)
  end

  defp delete_operations(name) do
    [
      Client.delete(%Namespace{name: name} |> to_k8s()),
      Client.delete(%Certificate{name: name, domains: []} |> to_k8s())
    ]
  end

  defp create_ns(name) do
    Client.run(Client.create(%Namespace{name: name} |> to_k8s()), cluster_name())
  end

  defp cluster_name do
    Application.get_env(:bonny, :cluster_name)
  end
end
