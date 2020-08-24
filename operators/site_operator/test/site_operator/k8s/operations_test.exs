defmodule SiteOperator.K8s.OperationsTest do
  use ExUnit.Case, async: true

  import SiteOperator.K8s.Operations

  describe "inner namespace creations" do
    test "all use the provided namespace" do
      namespaces =
        for op <-
              inner_ns_creations("my-app", "my-namespace", ["my-app.example.com"], "some-secret") do
          op.resource |> get_in(["metadata", "namespace"])
        end

      assert namespaces |> Enum.uniq() == ["my-namespace"]
    end

    test "all use the provided app-type name, because they're namespaced" do
      names =
        for op <-
              inner_ns_creations("my-app", "my-namespace", ["my-app.example.com"], "some-secret") do
          op.resource |> get_in(["metadata", "name"])
        end

      assert names |> Enum.uniq() == ["my-app"]
    end

    test "include a secret for the Phoenix app" do
      %{
        "apiVersion" => "v1",
        "kind" => "Secret",
        "metadata" => %{
          "name" => "my-app"
        },
        "type" => "Opaque",
        "data" => %{
          "SECRET_KEY_BASE" => secret_key_encoded
        }
      } =
        inner_ns_creations("my-app", "my-namespace", ["my-app.example.com"], "my-secret")
        |> Enum.find(fn op ->
          op.resource["kind"] == "Secret"
        end)
        |> Map.get(:resource)

      assert {:ok, "my-secret"} = Base.decode64(secret_key_encoded)
    end
  end
end
