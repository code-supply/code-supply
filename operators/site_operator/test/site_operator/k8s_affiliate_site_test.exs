defmodule SiteOperator.K8sAffiliateSiteTest do
  use ExUnit.Case, async: false

  alias SiteOperator.K8sAffiliateSite
  alias SiteOperator.AffiliateSite
  import Access

  @namespace "site-operator-test"
  @domain "testdomain.example.com"
  @cluster :test

  setup_all do
    conn = K8s.Conn.from_file("~/.kube/config", context: "site-operator-test")
    K8s.Cluster.Registry.add(@cluster, conn)

    ns_check = K8s.Client.get("v1", "Namespace", name: @namespace)

    case K8s.Client.run(ns_check, @cluster) do
      {:error, :not_found} ->
        :ok

      {:ok, %{"status" => _}} ->
        raise "#{@namespace} namespace exists from previous run. Please wait and try again."
    end

    delete =
      Hammox.protect(
        {K8sAffiliateSite, :delete, 1},
        AffiliateSite
      )

    on_exit(fn ->
      delete.(@namespace)
    end)

    Hammox.protect(
      K8sAffiliateSite,
      AffiliateSite,
      create: 2
    )
  end

  describe "creation" do
    @tag :external
    test "creates namespace with deployment, service, gateway, virtual service, certificate in istio-system",
         %{create_2: create} do
      {:ok, _} = create.(@namespace, @domain)

      [
        ok: %{"items" => deployments},
        ok: %{"items" => services},
        ok: %{"items" => gateways},
        ok: %{"items" => virtual_services},
        ok: certificate
      ] =
        K8s.Client.parallel(
          [
            list("apps/v1", "Deployment"),
            list("v1", "Service"),
            list("networking.istio.io/v1alpha3", "Gateway"),
            list("networking.istio.io/v1alpha3", "VirtualService"),
            K8s.Client.get("cert-manager.io/v1alpha2", "Certificate",
              namespace: "istio-system",
              name: @namespace
            )
          ],
          @cluster,
          []
        )

      assert length(deployments) == 1
      assert length(services) == 1
      assert length(gateways) == 1
      assert length(virtual_services) == 1

      assert get_in(deployments, [at(0), "spec", "replicas"]) == 1
      assert get_in(services, [at(0), "spec", "selector"]) == %{"so-app" => @namespace}
      assert get_in(gateways, [at(0), "spec", "servers", at(0), "port", "number"]) == 80
      assert get_in(gateways, [at(0), "spec", "servers", at(1), "port", "number"]) == 443
      assert get_in(virtual_services, [at(0), "spec", "hosts"]) == [@domain]
      assert get_in(certificate, ["spec", "dnsNames", all()]) == [@domain]
    end

    @tag :external
    test "returns error when we ask for an invalid name", %{create_2: create} do
      assert elem(create.("", ""), 0) == :error
    end

    @tag :external
    test "returns error when we ask for an invalid domain name", %{create_2: create} do
      assert elem(create.("good-namespace-name", "bad domain name"), 0) == :error
    end
  end

  defp list(version, kind) do
    K8s.Client.list(version, kind, namespace: @namespace)
  end
end
