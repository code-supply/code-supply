defmodule SiteOperator.K8sFactoriesTest do
  use ExUnit.Case, async: true

  import SiteOperator.K8sFactories

  test "generates a parameterised deployment" do
    deployment = deployment("my-name")

    assert get_in(deployment, [
             "metadata",
             "namespace"
           ]) == "my-name"

    assert get_in(deployment, [
             "spec",
             "selector",
             "matchLabels",
             "so-app"
           ]) ==
             "my-name"

    assert get_in(deployment, [
             "spec",
             "template",
             "metadata",
             "labels",
             "so-app"
           ]) == "my-name"

    assert get_in(deployment, [
             "spec",
             "template",
             "spec",
             "containers"
           ])
           |> Enum.at(0)
           |> Map.get("name") ==
             "app"
  end

  test "generates a namespace" do
    assert get_in(ns("my-name"), ["metadata", "name"]) == "my-name"
  end
end
