defmodule SiteOperator.K8s.ConversionsTest do
  use ExUnit.Case, async: true

  import SiteOperator.K8s.Conversions
  import Access

  alias SiteOperator.K8s.{
    AuthorizationPolicy,
    Certificate,
    Deployment,
    Gateway,
    Namespace,
    Secret,
    Service,
    VirtualService
  }

  @name "my-name"
  @namespace "my-namespace"
  @domains ["some-domain.example.com", "another-domain.biz"]
  @namespaced_domains ["my-namespace/some-domain.example.com", "my-namespace/another-domain.biz"]
  @secret_data %{"my-secret" => "stuff"}
  @image "nginx:1.2.3"

  setup do
    %{
      certificate: %Certificate{name: @namespace, domains: @domains} |> to_k8s(),
      deployment:
        %Deployment{
          name: @name,
          namespace: @namespace,
          image: @image,
          env_vars: %{"NON_SECRET_CONFIG" => "asdf"}
        }
        |> to_k8s(),
      gateway: %Gateway{name: @name, namespace: @namespace, domains: @domains} |> to_k8s(),
      namespace: %Namespace{name: @name} |> to_k8s(),
      policy:
        %AuthorizationPolicy{
          name: @name,
          namespace: @namespace,
          allow_all_from_namespaces: ["from-ns"],
          allow_all_with_methods: ["GET"]
        }
        |> to_k8s(),
      secret: %Secret{name: @name, namespace: @namespace, data: @secret_data} |> to_k8s(),
      service: %Service{name: @name, namespace: @namespace} |> to_k8s(),
      virtual_service:
        %VirtualService{
          name: @name,
          namespace: @namespace,
          gateways: ["virtual-service-gateway"],
          domains: @domains
        }
        |> to_k8s()
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
             ]) == [%{"name" => "http", "port" => 80, "targetPort" => 4000}]
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

    test "has a container with secret as env vars, http port", %{deployment: deployment} do
      assert [
               %{
                 "name" => "app",
                 "image" => image,
                 "ports" => ports,
                 "envFrom" => [%{"secretRef" => %{"name" => @name}}]
               }
             ] =
               get_in(deployment, [
                 "spec",
                 "template",
                 "spec",
                 "containers",
                 all()
               ])

      assert image == @image

      assert ports == [
               %{"name" => "http", "containerPort" => 4000}
             ]
    end

    test "can be turned back into a struct", %{deployment: deployment} do
      assert deployment |> from_k8s() == %Deployment{
               name: @name,
               image: @image,
               namespace: @namespace,
               env_vars: %{"NON_SECRET_CONFIG" => "asdf"}
             }

      {_, without_env_vars} =
        deployment |> pop_in(["spec", "template", "spec", "containers", at(0), "env"])

      assert without_env_vars |> from_k8s() == %Deployment{
               name: @name,
               image: @image,
               namespace: @namespace,
               env_vars: %{}
             }
    end
  end

  describe "secret" do
    test "named and namespaced correctly", %{secret: secret} do
      assert name_and_namespace(secret) == {@name, @namespace}
    end

    test "can be turned back into a struct", %{secret: secret} do
      assert secret |> from_k8s() == %Secret{
               name: @name,
               namespace: @namespace,
               data: @secret_data
             }
    end
  end

  describe "authorization policy" do
    test "named and namespaced correctly", %{policy: policy} do
      assert name_and_namespace(policy) == {@name, @namespace}
    end

    test "can be turned back into a struct", %{policy: policy} do
      assert policy |> from_k8s() == %AuthorizationPolicy{
               name: @name,
               namespace: @namespace,
               allow_all_from_namespaces: ["from-ns"],
               allow_all_with_methods: ["GET"]
             }
    end
  end

  describe "virtual service" do
    test "is translated correctly in the all-affable domain case" do
      assert %{
               "apiVersion" => "networking.istio.io/v1beta1",
               "kind" => "VirtualService",
               "metadata" => %{"name" => "my-vs", "namespace" => "my-vs-ns"},
               "spec" => %{
                 "gateways" => ["vs-gateway"],
                 "hosts" => ["foo.affable.app"],
                 "http" => [
                   %{
                     "match" => [%{"uri" => %{"regex" => "/[^.]?.*"}}],
                     "route" => [
                       %{"destination" => %{"host" => "app.my-vs-ns.svc.cluster.local"}}
                     ]
                   }
                 ]
               }
             } ==
               %VirtualService{
                 name: "my-vs",
                 namespace: "my-vs-ns",
                 gateways: ["vs-gateway"],
                 domains: ["foo.affable.app"]
               }
               |> to_k8s()
    end

    test "can be turned back into a struct", %{virtual_service: virtual_service} do
      assert %VirtualService{
               name: @name,
               namespace: @namespace,
               gateways: ["virtual-service-gateway"],
               domains: @domains
             } ==
               virtual_service |> from_k8s()
    end

    test "with custom domains, can do a round-trip" do
      vs = %VirtualService{
        name: @name,
        namespace: @namespace,
        gateways: ["virtual-service-gateway"],
        domains: "a.example.com",
        redirect: {"www.a.example.com", "a.example.com"}
      }

      assert vs == vs |> to_k8s() |> from_k8s()
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
      assert [
               %{
                 "port" => %{
                   "number" => 80,
                   "name" => "http",
                   "protocol" => "HTTP"
                 },
                 "hosts" => @namespaced_domains
               },
               %{
                 "port" => %{
                   "number" => 443,
                   "name" => "https",
                   "protocol" => "HTTPS"
                 },
                 "hosts" => @namespaced_domains,
                 "tls" => %{
                   "mode" => "SIMPLE",
                   "credentialName" => certificate |> get_in(["spec", "secretName"])
                 }
               }
             ] == get_in(gateway, ["spec", "servers"])
    end

    test "can be turned back into a struct", %{gateway: gateway} do
      assert %Gateway{
               name: @name,
               namespace: @namespace,
               domains: @domains
             } == gateway |> from_k8s()
    end
  end

  describe "certificate" do
    test "uses production letsencrypt issuer", %{certificate: certificate} do
      assert get_in(certificate, ["spec", "issuerRef", "name"]) ==
               "letsencrypt-production"

      assert get_in(certificate, ["spec", "issuerRef", "kind"]) == "ClusterIssuer"
    end

    test "named correctly, in istio-system namespace", %{certificate: certificate} do
      assert name_and_namespace(certificate) == {@namespace, "istio-system"}
    end

    test "sets appropriate secret name", %{certificate: certificate} do
      assert get_in(certificate, ["spec", "secretName"]) == "tls-my-namespace"
    end

    test "domain names are set", %{certificate: certificate} do
      assert get_in(certificate, ["spec", "dnsNames"]) == @domains
    end

    test "can be turned back into a struct", %{certificate: certificate} do
      assert certificate |> from_k8s() == %Certificate{name: @namespace, domains: @domains}
    end
  end

  defp name_and_namespace(resource) do
    {
      get_in(resource, ["metadata", "name"]),
      get_in(resource, ["metadata", "namespace"])
    }
  end
end
