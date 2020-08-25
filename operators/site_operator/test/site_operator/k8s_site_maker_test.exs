defmodule SiteOperator.K8sSiteMakerTest do
  use ExUnit.Case, async: true

  alias SiteOperator.{K8sSiteMaker, SiteMaker, MockK8s}
  alias SiteOperator.K8s.{AffiliateSite, Certificate, Namespace, Operation, Operations}

  import SiteOperator.K8sConversions, only: [to_k8s: 1]
  import Hammox

  @namespace "generatedname"
  @domains ["testdomain.example.com"]

  setup :verify_on_exit!

  setup do
    Hammox.protect(
      K8sSiteMaker,
      SiteMaker,
      create: 1,
      delete: 1,
      reconcile: 1
    )
  end

  describe "creation" do
    test "creates namespace with deployment, service, gateway, virtual service, certificate in istio-system",
         %{create_1: create} do
      ns = %Namespace{name: "customer-#{@namespace}"}
      ns_k8s = ns |> to_k8s

      cert = %Certificate{name: "customer-#{@namespace}", domains: @domains}
      cert_k8s = cert |> to_k8s

      expect(MockK8s, :execute, fn [
                                     %Operation{action: :create, resource: ^ns_k8s},
                                     %Operation{action: :create, resource: ^cert_k8s}
                                   ] ->
        expect(MockK8s, :execute, fn operations ->
          assert operations ==
                   Operations.inner_ns_creations(
                     "affiliate",
                     "customer-#{@namespace}",
                     @domains,
                     "my-awesome-secret"
                   )

          {:ok, "don't match on this"}
        end)

        {:ok, ""}
      end)

      {:ok, _} =
        create.(%AffiliateSite{
          name: @namespace,
          domains: @domains,
          secret_key_base: "my-awesome-secret"
        })
    end

    test "returns error when we ask for an empty name, empty domain, or no domains", %{
      create_1: create
    } do
      assert create.(%AffiliateSite{
               name: "",
               domains: ["yo.com"],
               secret_key_base: ""
             }) == {:error, "Empty name"}

      assert create.(%AffiliateSite{
               name: "hi",
               domains: ["yo.com", ""],
               secret_key_base: ""
             }) == {:error, "Empty domain"}

      assert create.(%AffiliateSite{
               name: "hi",
               domains: [],
               secret_key_base: ""
             }) == {:error, "No domains"}
    end

    test "returns error when we get a k8s error", %{create_1: create} do
      MockK8s
      |> stub(:execute, fn _ ->
        {:error, "Bad news"}
      end)

      result = create.(%AffiliateSite{name: "<>@", domains: ["!!"], secret_key_base: ""})
      assert elem(result, 0) == :error
      assert elem(result, 1) == "Bad news"
    end
  end

  describe "deletion" do
    test "deletes namespace and certificate in parallel", %{delete_1: delete} do
      MockK8s
      |> expect(:execute, fn operations ->
        assert operations == Operations.deletions("customer-#{@namespace}")
        {:ok, "pass message through"}
      end)

      {:ok, "pass message through"} = delete.(@namespace)
    end
  end

  describe "reconciliation" do
    test "does nothing when namespace and cert are available", %{reconcile_1: reconcile} do
      stub(MockK8s, :execute, fn [%Operation{action: :get}, %Operation{action: :get}] ->
        {:ok, "Some message"}
      end)

      assert reconcile.(%AffiliateSite{
               name: @namespace,
               domains: @domains,
               secret_key_base: "a-secret"
             }) == {:ok, :nothing_to_do}
    end

    test "creates missing certificate", %{reconcile_1: reconcile} do
      cert = %Certificate{name: "customer-#{@namespace}", domains: @domains}
      cert_k8s = cert |> to_k8s

      stub(MockK8s, :execute, fn [_, %Operation{action: :get, resource: ^cert_k8s}] ->
        expect(MockK8s, :execute, fn [%Operation{action: :create, resource: ^cert_k8s}] ->
          {:ok, ""}
        end)

        {:error, some_resources_missing: [cert]}
      end)

      {:ok, recreated: [^cert]} =
        reconcile.(%AffiliateSite{
          name: @namespace,
          domains: @domains,
          secret_key_base: "a-secret"
        })
    end

    test "creates missing namespace and its resources", %{reconcile_1: reconcile} do
      ns = %Namespace{name: "customer-#{@namespace}"}
      ns_k8s = ns |> to_k8s

      stub(MockK8s, :execute, fn [%Operation{action: :get, resource: ^ns_k8s}, _] ->
        expect(MockK8s, :execute, fn [%Operation{action: :create, resource: ^ns_k8s}] ->
          expect(MockK8s, :execute, fn operations ->
            assert operations ==
                     Operations.inner_ns_creations(
                       "affiliate",
                       "customer-#{@namespace}",
                       @domains,
                       "a-new-secret"
                     )

            {:ok, "don't match on this"}
          end)

          {:ok, ""}
        end)

        {:error, some_resources_missing: [ns]}
      end)

      {:ok, recreated: [^ns]} =
        reconcile.(%AffiliateSite{
          name: @namespace,
          domains: @domains,
          secret_key_base: "a-new-secret"
        })
    end
  end
end