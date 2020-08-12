defmodule SiteOperator.K8sAffiliateSiteTest do
  use ExUnit.Case, async: true

  alias SiteOperator.{K8sAffiliateSite, AffiliateSite, MockK8s}
  alias SiteOperator.K8s.{Certificate, Namespace, Operation, Operations}

  import SiteOperator.K8sFactories, only: [to_k8s: 1]
  import Hammox

  @namespace "site-operator-test"
  @domain "testdomain.example.com"

  setup :verify_on_exit!

  setup do
    Hammox.protect(
      K8sAffiliateSite,
      AffiliateSite,
      create: 2,
      delete: 1,
      reconcile: 2
    )
  end

  describe "creation" do
    test "creates namespace with deployment, service, gateway, virtual service, certificate in istio-system",
         %{create_2: create} do
      MockK8s
      |> expect(:execute, fn [%Operation{action: :create, resource: resource}] ->
        assert resource == %Namespace{name: @namespace} |> to_k8s()

        MockK8s
        |> expect(:execute, fn operations ->
          assert operations == Operations.create_operations(@namespace, @domain)
          {:ok, "don't match on this"}
        end)

        {:ok, ""}
      end)

      {:ok, _} = create.(@namespace, @domain)
    end

    test "returns error when we ask for an empty name or domain", %{create_2: create} do
      assert create.("", "") == {:error, "Empty name"}
      assert create.("hi", "") == {:error, "Empty domain"}
    end

    test "returns error when we get a k8s error", %{create_2: create} do
      MockK8s
      |> stub(:execute, fn _ ->
        {:error, "Bad news"}
      end)

      result = create.("<>@", "!!")
      assert elem(result, 0) == :error
      assert elem(result, 1) == "Bad news"
    end
  end

  describe "deletion" do
    test "deletes namespace and certificate in parallel", %{delete_1: delete} do
      MockK8s
      |> expect(:execute, fn operations ->
        assert operations == Operations.delete_operations(@namespace)
        {:ok, "pass message through"}
      end)

      {:ok, "pass message through"} = delete.(@namespace)
    end
  end

  describe "reconciliation" do
    test "does nothing when namespace and cert are available", %{reconcile_2: reconcile} do
      stub(MockK8s, :execute, fn [%Operation{action: :get}, %Operation{action: :get}] ->
        {:ok, "Some message"}
      end)

      assert reconcile.(@namespace, @domain) == {:ok, :nothing_to_do}
    end

    test "creates missing certificate", %{reconcile_2: reconcile} do
      cert = %Certificate{name: @namespace, domains: [@domain]}
      cert_k8s = cert |> to_k8s

      stub(MockK8s, :execute, fn [_, %Operation{action: :get, resource: ^cert_k8s}] ->
        expect(MockK8s, :execute, fn [%Operation{action: :create, resource: ^cert_k8s}] ->
          {:ok, ""}
        end)

        {:error, some_resources_missing: [cert]}
      end)

      {:ok, recreated: [^cert]} = reconcile.(@namespace, @domain)
    end

    test "creates missing namespace and its resources", %{reconcile_2: reconcile} do
      ns = %Namespace{name: @namespace}
      ns_k8s = ns |> to_k8s

      stub(MockK8s, :execute, fn [%Operation{action: :get, resource: ^ns_k8s}, _] ->
        expect(MockK8s, :execute, fn [%Operation{action: :create, resource: ^ns_k8s}] ->
          {:ok, ""}
        end)

        {:error, some_resources_missing: [ns]}
      end)

      {:ok, recreated: [^ns]} = reconcile.(@namespace, @domain)
    end
  end
end
