defmodule SiteOperator.K8s.OperationsTest do
  use ExUnit.Case, async: true

  import SiteOperator.K8s.Operations

  test "inner namespace creations include a secret for the Phoenix app" do
    %{
      "apiVersion" => "v1",
      "kind" => "Secret",
      "metadata" => %{
        "name" => "affiliate"
      },
      "type" => "Opaque",
      "data" => %{
        "SECRET_KEY_BASE" => secret_key_encoded
      }
    } =
      inner_ns_creations("my-app", "my-app.example.com", "my-secret")
      |> Enum.find(fn op ->
        op.resource["kind"] == "Secret"
      end)
      |> Map.get(:resource)

    assert {:ok, "my-secret"} = Base.decode64(secret_key_encoded)
  end
end
