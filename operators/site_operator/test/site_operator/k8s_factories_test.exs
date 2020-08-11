defmodule SiteOperator.K8sFactoriesTest do
  use ExUnit.Case, async: true

  import SiteOperator.K8sFactories
  import Access

  alias SiteOperator.K8s.{
    Certificate,
    Deployment,
    Gateway,
    Namespace,
    Service,
    VirtualService
  }

  @name "my-name"
  @domain "my-domain.com"
  @domains [@domain, "another-domain.biz"]

  setup do
    %{
      certificate: %Certificate{name: @name, domains: @domains} |> to_k8s(),
      deployment: %Deployment{name: @name} |> to_k8s(),
      gateway: %Gateway{name: @name, domain: @domain} |> to_k8s(),
      namespace: %Namespace{name: @name} |> to_k8s(),
      service: %Service{name: @name} |> to_k8s(),
      virtual_service: %VirtualService{name: @name, domain: @domain} |> to_k8s()
    }
  end

  describe "namespace" do
    test "has prefixed name", %{namespace: namespace} do
      assert get_in(namespace, ["metadata", "name"]) == "customer-#{@name}"
    end

    test "enables Istio sidecar injection", %{namespace: namespace} do
      assert get_in(namespace, ["metadata", "labels", "istio-injection"]) == "enabled"
    end
  end

  describe "service" do
    test "in correct namespace", %{service: service} do
      assert get_in(service, [
               "metadata",
               "namespace"
             ]) == "customer-#{@name}"
    end

    test "selects correct pods", %{service: service} do
      assert get_in(service, [
               "spec",
               "selector",
               "so-app"
             ]) ==
               @name
    end

    test "sets up a port", %{service: service} do
      assert get_in(service, [
               "spec",
               "ports"
             ]) == [%{"name" => "http", "port" => 80}]
    end
  end

  describe "deployment" do
    test "named and namespaced correctly", %{deployment: deployment} do
      assert name_and_namespace(deployment) == {@name, "customer-#{@name}"}
    end

    test "matches on correct labels", %{deployment: deployment} do
      assert get_in(deployment, [
               "spec",
               "selector",
               "matchLabels",
               "so-app"
             ]) ==
               @name

      assert get_in(deployment, [
               "spec",
               "template",
               "metadata",
               "labels",
               "so-app"
             ]) == @name
    end

    test "has a container", %{deployment: deployment} do
      assert get_in(deployment, [
               "spec",
               "template",
               "spec",
               "containers",
               at(0),
               "name"
             ]) ==
               "app"
    end
  end

  describe "virtual service" do
    test "named and namespaced correctly", %{virtual_service: virtual_service} do
      assert name_and_namespace(virtual_service) == {@name, "customer-#{@name}"}
    end

    test "external host is set", %{virtual_service: virtual_service} do
      assert get_in(virtual_service, ["spec", "hosts"]) == [@domain]
    end

    test "internal host is set", %{virtual_service: virtual_service} do
      assert get_in(virtual_service, [
               "spec",
               "http",
               at(0),
               "route",
               at(0),
               "destination",
               "host"
             ]) == @name
    end

    test "gateway is tied", %{virtual_service: virtual_service, gateway: gateway} do
      assert get_in(virtual_service, [
               "spec",
               "gateways",
               all()
             ]) == [get_in(gateway, ["metadata", "name"])]
    end

    test "matches on /", %{virtual_service: virtual_service} do
      assert get_in(virtual_service, [
               "spec",
               "http",
               at(0),
               "match",
               at(0),
               "uri",
               "prefix"
             ]) == "/"
    end
  end

  describe "gateway" do
    test "named and namespaced correctly", %{gateway: gateway} do
      assert name_and_namespace(gateway) == {@name, "customer-#{@name}"}
    end

    test "configures servers with insecure and TLS endpoints", %{
      gateway: gateway,
      certificate: certificate
    } do
      assert get_in(gateway, ["spec", "servers"]) ==
               [
                 %{
                   "port" => %{
                     "number" => 80,
                     "name" => "http",
                     "protocol" => "HTTP"
                   },
                   "hosts" => [@domain],
                   "tls" => %{
                     "httpsRedirect" => true
                   }
                 },
                 %{
                   "port" => %{
                     "number" => 443,
                     "name" => "https",
                     "protocol" => "HTTPS"
                   },
                   "hosts" => [@domain],
                   "tls" => %{
                     "mode" => "SIMPLE",
                     "credentialName" => certificate |> get_in(["spec", "secretName"])
                   }
                 }
               ]
    end
  end

  describe "certificate" do
    test "uses production letsencrypt issuer", %{certificate: certificate} do
      assert get_in(certificate, ["spec", "issuerRef", "name"]) ==
               "letsencrypt-production"

      assert get_in(certificate, ["spec", "issuerRef", "kind"]) == "ClusterIssuer"
    end

    test "named correctly, in istio-system namespace", %{certificate: certificate} do
      assert name_and_namespace(certificate) == {@name, "istio-system"}
    end

    test "sets appropriate secret name", %{certificate: certificate} do
      assert get_in(certificate, ["spec", "secretName"]) == "tls-my-name"
    end

    test "domain names are set", %{certificate: certificate} do
      assert get_in(certificate, ["spec", "dnsNames"]) == @domains
    end
  end

  defp name_and_namespace(resource) do
    {
      get_in(resource, ["metadata", "name"]),
      get_in(resource, ["metadata", "namespace"])
    }
  end
end
