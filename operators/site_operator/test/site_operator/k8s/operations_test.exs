defmodule SiteOperator.K8s.OperationsTest do
  use ExUnit.Case, async: true

  import SiteOperator.K8s.Operations

  alias SiteOperator.PhoenixSites.PhoenixSite

  setup do
    site = %PhoenixSite{
      name: "my-namespace",
      image: "my-image",
      domains: ["host1.affable.app"],
      secret_key_base: "some-secret",
      live_view_signing_salt: "live-view-salt"
    }

    %{
      site: site,
      initial_creations: initial_creations(site),
      inner_creations: inner_ns_creations(site)
    }
  end

  describe "initial creations" do
    test "include namespace", %{initial_creations: creations} do
      assert creations |> find_kind("Namespace") == %{
               "apiVersion" => "v1",
               "kind" => "Namespace",
               "metadata" => %{
                 "labels" => %{"istio-injection" => "enabled"},
                 "name" => "my-namespace"
               }
             }
    end

    test "do not include certificate, because they can use the wildcard", %{
      initial_creations: creations
    } do
      refute creations |> find_operation("Certificate")
    end
  end

  describe "deletions" do
    test "include certificates when there are custom domains (they live in a different NS)", %{
      site: site
    } do
      custom_domain_site = %{site | domains: ["host1.affable.app", "something.example.com"]}
      deletions = deletions(custom_domain_site)

      assert %{"spec" => %{"dnsNames" => ["something.example.com"]}} =
               deletions |> find_kind("Certificate")
    end
  end

  describe "inner namespace creations" do
    test "all use the provided namespace", %{inner_creations: creations} do
      namespaces =
        for op <- creations do
          op.resource |> get_in(["metadata", "namespace"])
        end

      assert namespaces |> Enum.uniq() == ["my-namespace"]
    end

    test "all use a static name, because they're namespaced", %{inner_creations: creations} do
      names =
        for op <- creations do
          op.resource |> get_in(["metadata", "name"])
        end

      assert names |> Enum.uniq() == ["app"]
    end

    test "include a virtual service that makes use of affable's wildcard cert", %{
      inner_creations: creations
    } do
      assert %{
               "apiVersion" => "networking.istio.io/v1beta1",
               "kind" => "VirtualService",
               "metadata" => %{"name" => "app", "namespace" => "my-namespace"},
               "spec" => %{
                 "gateways" => ["affable/affable"],
                 "hosts" => ["host1.affable.app"],
                 "http" => [
                   %{
                     "match" => [%{"uri" => %{"prefix" => "/"}}],
                     "route" => [
                       %{"destination" => %{"host" => "app.my-namespace.svc.cluster.local"}}
                     ]
                   }
                 ]
               }
             } == creations |> find_kind("VirtualService")
    end

    test "include auth rules for site change access", %{inner_creations: creations} do
      %{
        "apiVersion" => "security.istio.io/v1beta1",
        "kind" => "AuthorizationPolicy",
        "metadata" => %{
          "name" => "app"
        },
        "spec" => %{
          "rules" => [
            %{
              "from" => [
                %{"source" => %{"namespaces" => ["affable"]}}
              ]
            },
            %{
              "to" => [
                %{"operation" => %{"methods" => ["GET", "HEAD", "OPTIONS"]}}
              ]
            }
          ]
        }
      } = creations |> find_kind("AuthorizationPolicy")
    end

    test "include a secret for the Phoenix app", %{inner_creations: creations} do
      %{
        "apiVersion" => "v1",
        "kind" => "Secret",
        "metadata" => %{
          "name" => "app"
        },
        "type" => "Opaque",
        "data" => %{
          "SECRET_KEY_BASE" => secret_key_encoded,
          "LIVE_VIEW_SIGNING_SALT" => live_view_signing_salt_encoded
        }
      } = creations |> find_kind("Secret")

      assert {:ok, "some-secret"} = Base.decode64(secret_key_encoded)
      assert {:ok, "live-view-salt"} = Base.decode64(live_view_signing_salt_encoded)
    end

    test "sets the fetch URLs in the deployment", %{inner_creations: creations} do
      assert %{
               "name" => "PREVIEW_URL",
               "value" => "http://affable.affable/api/sites/my-namespace/preview"
             } in (creations |> find_kind("Deployment") |> env_vars())

      assert %{
               "name" => "PUBLISHED_URL",
               "value" => "http://affable.affable/api/sites/my-namespace"
             } in (creations |> find_kind("Deployment") |> env_vars())
    end

    test "sets the checked origins in the deployment, so that new hosts trigger new rollout", %{
      site: site
    } do
      creations =
        inner_ns_creations(%{site | domains: ["host1.affable.app", "www.custom-domain.com"]})

      assert %{
               "name" => "CHECK_ORIGINS",
               "value" => "https://host1.affable.app https://www.custom-domain.com"
             } in (creations |> find_kind("Deployment") |> env_vars())
    end

    defp env_vars(k8s_deployment) do
      %{
        "kind" => "Deployment",
        "spec" => %{
          "template" => %{
            "spec" => %{
              "containers" => [
                %{
                  "env" => env_vars
                }
              ]
            }
          }
        }
      } = k8s_deployment

      env_vars
    end

    defp find_operation(creations, kind) do
      creations
      |> Enum.find(fn op ->
        op.resource["kind"] == kind
      end)
    end

    defp find_kind(creations, kind) do
      find_operation(creations, kind)
      |> Map.get(:resource)
    end
  end
end
