defmodule SiteOperator.K8sConversionsTest do
  use ExUnit.Case, async: true

  import SiteOperator.K8sConversions
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
  @namespace "my-namespace"
  @domains ["some-domain.example.com", "another-domain.biz"]

  setup do
    %{
      certificate: %Certificate{name: @name, domains: @domains} |> to_k8s(),
      deployment: %Deployment{name: @name, namespace: @namespace} |> to_k8s(),
      gateway: %Gateway{name: @name, namespace: @namespace, domains: @domains} |> to_k8s(),
      namespace: %Namespace{name: @name} |> to_k8s(),
      service: %Service{name: @name, namespace: @namespace} |> to_k8s(),
      virtual_service:
        %VirtualService{name: @name, namespace: @namespace, domains: @domains} |> to_k8s()
    }
  end

  describe "namespace" do
    test "has name", %{namespace: namespace} do
      assert get_in(namespace, ["metadata", "name"]) == @name
    end

    test "enables Istio sidecar injection", %{namespace: namespace} do
      assert get_in(namespace, ["metadata", "labels", "istio-injection"]) == "enabled"
    end

    test "can be turned back into a struct", %{namespace: namespace} do
      assert namespace |> from_k8s() == %Namespace{name: @name}
    end
  end

  describe "service" do
    test "named and namespaced correctly", %{service: service} do
      assert name_and_namespace(service) == {@name, @namespace}
    end

    test "selects correct pods", %{service: service, deployment: deployment} do
      assert get_in(service, [
               "spec",
               "selector"
             ]) ==
               get_in(deployment, ["spec", "selector", "matchLabels"])
    end

    test "sets up a port", %{service: service} do
      assert get_in(service, [
               "spec",
               "ports"
             ]) == [%{"name" => "http", "port" => 80}]
    end

    test "can be turned back into a struct", %{service: service} do
      assert service |> from_k8s() == %Service{name: @name, namespace: @namespace}
    end
  end

  describe "deployment" do
    test "named and namespaced correctly", %{deployment: deployment} do
      assert name_and_namespace(deployment) == {@name, @namespace}
    end

    test "matches on app label, has version", %{deployment: deployment} do
      assert get_in(deployment, [
               "spec",
               "selector",
               "matchLabels",
               "app"
             ]) ==
               @name

      assert get_in(deployment, [
               "spec",
               "template",
               "metadata",
               "labels",
               "app"
             ]) == @name

      assert get_in(deployment, [
               "spec",
               "template",
               "metadata",
               "labels",
               "version"
             ]) == "1"
    end

    test "has a container with secret as env vars", %{deployment: deployment} do
      assert get_in(deployment, [
               "spec",
               "template",
               "spec",
               "containers",
               all()
             ]) == [
               %{
                 "name" => "app",
                 "image" =>
                   "eu.gcr.io/code-supply/affiliate@sha256:a3fd9bf69c19da78530d74ae179bc29520fcc5e1e91570a66d31d1b9865f9eff",
                 "envFrom" => [%{"secretRef" => %{"name" => @name}}]
               }
             ]
    end

    test "can be turned back into a struct", %{deployment: deployment} do
      assert deployment |> from_k8s() == %Deployment{name: @name, namespace: @namespace}
    end
  end

  describe "virtual service" do
    test "named and namespaced correctly", %{virtual_service: virtual_service} do
      assert name_and_namespace(virtual_service) == {@name, @namespace}
    end

    test "external host is set", %{virtual_service: virtual_service} do
      assert get_in(virtual_service, ["spec", "hosts"]) == @domains
    end

    test "internal host is set", %{virtual_service: virtual_service, service: service} do
      assert get_in(virtual_service, [
               "spec",
               "http",
               at(0),
               "route",
               at(0),
               "destination",
               "host"
             ]) == get_in(service, ["metadata", "name"])
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

    test "can be turned back into a struct", %{virtual_service: virtual_service} do
      assert virtual_service |> from_k8s() == %VirtualService{
               name: @name,
               namespace: @namespace,
               domains: @domains
             }
    end
  end

  describe "gateway" do
    test "named and namespaced correctly", %{gateway: gateway} do
      assert name_and_namespace(gateway) == {@name, @namespace}
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
                   "hosts" => @domains,
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
                   "hosts" => @domains,
                   "tls" => %{
                     "mode" => "SIMPLE",
                     "credentialName" => certificate |> get_in(["spec", "secretName"])
                   }
                 }
               ]
    end

    test "can be turned back into a struct", %{gateway: gateway} do
      assert gateway |> from_k8s() == %Gateway{
               name: @name,
               namespace: @namespace,
               domains: @domains
             }
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

    test "can be turned back into a struct", %{certificate: certificate} do
      assert certificate |> from_k8s() == %Certificate{name: @name, domains: @domains}
    end
  end

  defp name_and_namespace(resource) do
    {
      get_in(resource, ["metadata", "name"]),
      get_in(resource, ["metadata", "namespace"])
    }
  end
end
