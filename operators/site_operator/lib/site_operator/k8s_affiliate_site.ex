defmodule SiteOperator.K8sAffiliateSite do
  @behaviour SiteOperator.AffiliateSite
  import SiteOperator.K8sFactories

  alias K8s.Client

  @impl SiteOperator.AffiliateSite
  def create(name, domain) do
    case create_ns(name) do
      {:ok, _} ->
        case Client.parallel(create_operations(name, domain), cluster_name(), []) do
          [ok: _, ok: _, ok: _, ok: _, ok: _] ->
            {:ok, "Site created"}

          [ok: _, ok: _, error: _gateway_error, error: _vs_error, error: _cert_error] ->
            {:error, "Bad domain name"}
        end

      {:error, %{body: body}} ->
        {:error, body}
    end
  end

  @impl SiteOperator.AffiliateSite
  def delete(name) do
    [ok: _, ok: _] = Client.parallel(delete_operations(name), cluster_name(), [])
    {:ok, ""}
  end

  defp create_operations(name, domain) do
    Enum.map(
      [
        deployment(name),
        service(name),
        gateway(name, domain),
        virtual_service(name, domain),
        certificate(name, domain)
      ],
      &Client.create/1
    )
  end

  defp delete_operations(name) do
    [
      Client.delete("v1", "Namespace", name: name),
      Client.delete("cert-manager.io/v1alpha2", "Certificate",
        name: name,
        namespace: "istio-system"
      )
    ]
  end

  defp create_ns(name) do
    Client.run(Client.create(ns(name)), cluster_name())
  end

  defp cluster_name do
    Application.get_env(:bonny, :cluster_name)
  end
end
