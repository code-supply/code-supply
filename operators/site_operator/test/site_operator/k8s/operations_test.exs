defmodule SiteOperator.K8s.OperationsTest do
  use ExUnit.Case, async: true

  import SiteOperator.K8s.Operations

  alias SiteOperator.K8s.AffiliateSite

  setup do
    %{
      initial_creations:
        initial_creations("my-namespace", ["host1.affable.app", "www.custom-domain.com"]),
      inner_creations:
        inner_ns_creations(%AffiliateSite{
          name: "my-namespace",
          image: "my-image",
          domains: ["host1.affable.app", "www.custom-domain.com"],
          secret_key_base: "some-secret",
          distribution_cookie: "some-cookie"
        })
    }
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

      assert names |> Enum.uniq() == ["affiliate"]
    end

    test "include a secret for the Phoenix app", %{inner_creations: creations} do
      %{
        "apiVersion" => "v1",
        "kind" => "Secret",
        "metadata" => %{
          "name" => "affiliate"
        },
        "type" => "Opaque",
        "data" => %{
          "SECRET_KEY_BASE" => secret_key_encoded,
          "RELEASE_COOKIE" => cookie_encoded
        }
      } = creations |> find_kind("Secret")

      assert {:ok, "some-secret"} = Base.decode64(secret_key_encoded)
      assert {:ok, "some-cookie"} = Base.decode64(cookie_encoded)
    end

    test "sets the checked origins in the deployment, so that new hosts trigger new rollout", %{
      inner_creations: creations
    } do
      assert %{
               "name" => "CHECK_ORIGINS",
               "value" => "https://host1.affable.app https://www.custom-domain.com"
             } in (creations |> find_kind("Deployment") |> env_vars())
    end

    test "sets the elixir erl options, so that we have a predictable distribution port", %{
      inner_creations: creations
    } do
      deployment = creations |> find_kind("Deployment")

      assert %{
               "name" => "ELIXIR_ERL_OPTIONS",
               "value" => "-kernel inet_dist_listen_min 5555 inet_dist_listen_max 5555"
             } in (deployment |> env_vars())
    end

    test "sets the distribution mode to 'name' and includes the pod IP", %{
      inner_creations: creations
    } do
      deployment = creations |> find_kind("Deployment")

      assert [
               %{
                 "name" => "POD_IP",
                 "valueFrom" => %{
                   "fieldRef" => %{"fieldPath" => "status.podIP"}
                 }
               }
               | _
             ] = deployment |> env_vars()

      assert %{
               "name" => "RELEASE_NODE",
               "value" => "affable@$(POD_IP)"
             } in (deployment |> env_vars())

      assert %{
               "name" => "RELEASE_DISTRIBUTION",
               "value" => "name"
             } in (deployment |> env_vars())
    end

    test "permits the default service account to list endpoints in the control plane namespace",
         %{initial_creations: creations} do
      binding = creations |> find_kind("RoleBinding")

      assert binding == %{
               "kind" => "RoleBinding",
               "apiVersion" => "rbac.authorization.k8s.io/v1",
               "metadata" => %{
                 "name" => "endpoint-listing-for-my-namespace",
                 "namespace" => "affable"
               },
               "roleRef" => %{
                 "apiGroup" => "rbac.authorization.k8s.io",
                 "kind" => "ClusterRole",
                 "name" => "endpoint-lister"
               },
               "subjects" => [
                 %{"kind" => "ServiceAccount", "name" => "default", "namespace" => "my-namespace"}
               ]
             }
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

    defp find_kind(creations, kind) do
      creations
      |> Enum.find(fn op ->
        op.resource["kind"] == kind
      end)
      |> Map.get(:resource)
    end
  end
end
