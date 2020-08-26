defmodule SiteOperator.K8s.OperationsTest do
  use ExUnit.Case, async: true

  import SiteOperator.K8s.Operations

  alias SiteOperator.K8s.AffiliateSite

  describe "inner namespace creations" do
    test "all use the provided namespace" do
      namespaces =
        for op <-
              inner_ns_creations(%AffiliateSite{
                name: "my-namespace",
                image: "my-image",
                domains: ["my-app.example.com"],
                secret_key_base: "some-secret",
                distribution_cookie: "some-cookie"
              }) do
          op.resource |> get_in(["metadata", "namespace"])
        end

      assert namespaces |> Enum.uniq() == ["my-namespace"]
    end

    test "all use a static name, because they're namespaced" do
      names =
        for op <-
              inner_ns_creations(%AffiliateSite{
                name: "my-namespace",
                image: "my-image",
                domains: ["my-app.example.com"],
                secret_key_base: "some-secret",
                distribution_cookie: "cookie"
              }) do
          op.resource |> get_in(["metadata", "name"])
        end

      assert names |> Enum.uniq() == ["affiliate"]
    end

    test "include a secret for the Phoenix app" do
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
      } =
        inner_ns_creations(%AffiliateSite{
          name: "my-namespace",
          image: "my-image",
          domains: ["my-app.example.com"],
          secret_key_base: "my-secret",
          distribution_cookie: "cookie"
        })
        |> find_kind("Secret")

      assert {:ok, "my-secret"} = Base.decode64(secret_key_encoded)
      assert {:ok, "cookie"} = Base.decode64(cookie_encoded)
    end

    test "set the checked origins in the deployment, so that new hosts trigger new rollout" do
      %{
        "kind" => "Deployment",
        "spec" => %{
          "template" => %{
            "spec" => %{
              "containers" => [
                %{
                  "env" => [
                    %{
                      "name" => "CHECK_ORIGINS",
                      "value" => origins
                    }
                  ]
                }
              ]
            }
          }
        }
      } =
        inner_ns_creations(%AffiliateSite{
          name: "ns",
          image: "some-image",
          domains: ["host1.affable.app", "www.custom-domain.com"],
          secret_key_base: "secret",
          distribution_cookie: "cookie"
        })
        |> find_kind("Deployment")

      assert origins == "https://host1.affable.app https://www.custom-domain.com"
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
