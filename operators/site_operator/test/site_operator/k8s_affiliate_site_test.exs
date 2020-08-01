defmodule SiteOperator.K8sAffiliateSiteTest do
  use ExUnit.Case, async: false

  alias SiteOperator.K8sAffiliateSite
  alias SiteOperator.AffiliateSite

  @namespace "site-operator-test"

  @tag :external
  setup_all do
    conn = K8s.Conn.from_file("~/.kube/config", context: "site-operator-test")
    K8s.Cluster.Registry.add(:test, conn)

    ns_check = K8s.Client.get("v1", "Namespace", name: @namespace)

    case K8s.Client.run(ns_check, :test) do
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
      create: 1
    )
  end

  describe "creation" do
    test "creates a namespace with a deployment", %{create_1: create} do
      create.(@namespace)

      operation = K8s.Client.list("apps/v1", "Deployment", namespace: @namespace)
      {:ok, %{"items" => [deployment | []]}} = K8s.Client.run(operation, :test)
      assert deployment["spec"]["replicas"] == 1
    end
  end
end
