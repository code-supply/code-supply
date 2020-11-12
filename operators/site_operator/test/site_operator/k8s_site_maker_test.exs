defmodule SiteOperator.K8sSiteMakerTest do
  use ExUnit.Case, async: true

  alias SiteOperator.{K8sSiteMaker, SiteMaker, MockK8s}

  alias SiteOperator.K8s.{
    AffiliateSite,
    Certificate,
    Namespace,
    RoleBinding,
    Service,
    Operation,
    Operations,
    VirtualService
  }

  import SiteOperator.K8s.Conversions
  import SiteOperator.AffiliateSiteFixtures

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

  defp deployment() do
    Operations.deployment(
      %AffiliateSite{
        name: @namespace,
        domains: @domains
      }
      |> from_k8s()
    )
  end

  describe "creation" do
    test "executes operation batches in order",
         %{create_1: create} do
      ns = Operations.create(%Namespace{name: @namespace})
      cert = Operations.create(%Certificate{name: @namespace, domains: @domains})

      service = Operations.create(%Service{name: "please", namespace: @namespace})

      batch_1 = [ns, cert]
      batch_2 = [service]

      MockK8s
      |> expect(:execute, fn [^ns, ^cert] ->
        {:ok, []}
      end)
      |> expect(:execute, fn [^service] ->
        {:ok, []}
      end)

      {:ok, _} = create.([batch_1, batch_2])
    end

    test "returns error when we get a k8s error", %{create_1: create} do
      MockK8s
      |> stub(:execute, fn _ ->
        {:error, "Bad news"}
      end)

      result = create.([[Operations.create(%Namespace{name: @namespace})]])

      assert elem(result, 0) == :error
      assert elem(result, 1) == "Bad news"
    end
  end

  describe "deletion" do
    test "deletes initial resources in parallel", %{delete_1: delete} do
      MockK8s
      |> expect(:execute, fn operations ->
        assert operations ==
                 Operations.deletions(affiliate_site_no_custom_domain(name: @namespace))

        {:ok, []}
      end)

      {:ok, []} = delete.(affiliate_site_no_custom_domain(name: @namespace))
    end
  end

  describe "reconciliation" do
    test "does nothing when the top-level resources are available with insignificant differences",
         %{
           reconcile_1: reconcile
         } do
      MockK8s
      |> stub(:execute, fn [
                             %Operation{action: :get},
                             %Operation{action: :get},
                             %Operation{action: :get},
                             %Operation{action: :get}
                           ] ->
        {:ok, [%{}, %{}, %{}, deployment()]}
      end)

      assert reconcile.(%AffiliateSite{name: @namespace, domains: @domains}) ==
               {:ok, :nothing_to_do}
    end

    test "creates missing rolebinding", %{reconcile_1: reconcile} do
      binding = %RoleBinding{
        name: "endpoint-listing-for-#{@namespace}",
        namespace: "affable",
        role_kind: "ClusterRole",
        role_name: "endpoint-lister",
        subjects: [%{kind: "ServiceAccount", name: "default", namespace: @namespace}]
      }

      binding_k8s = binding |> to_k8s

      MockK8s
      |> expect(:execute, fn outer_ops ->
        assert %Operation{action: :get, resource: binding_k8s} in outer_ops
        {:error, some_resources_missing: [binding]}
      end)
      |> expect(:execute, fn [%Operation{action: :create, resource: ^binding_k8s}] ->
        {:ok, []}
      end)

      {:ok, recreated: [^binding]} =
        reconcile.(%AffiliateSite{name: @namespace, domains: @domains})
    end

    test "creates missing namespace and its resources", %{reconcile_1: reconcile} do
      ns = %Namespace{name: @namespace}
      ns_k8s = ns |> to_k8s

      site = %AffiliateSite{
        name: @namespace,
        domains: @domains
      }

      expected_inner_operations = Operations.inner_ns_creations(site |> from_k8s())

      MockK8s
      |> expect(:execute, fn [%Operation{action: :get, resource: ^ns_k8s} | _] ->
        {:error, some_resources_missing: [ns]}
      end)
      |> expect(:execute, fn [%Operation{action: :create, resource: ^ns_k8s}] ->
        {:ok, []}
      end)
      |> expect(:execute, fn ^expected_inner_operations ->
        {:ok, []}
      end)

      {:ok, recreated: [^ns]} = reconcile.(site)
    end

    test "upgrades deployments when changed", %{reconcile_1: reconcile} do
      ns = %Namespace{name: @namespace}
      ns_k8s = ns |> to_k8s

      deployment = deployment()

      outdated_deployment = %{deployment | image: "old-image"}

      deployment_k8s = deployment |> to_k8s

      site = %AffiliateSite{
        name: @namespace,
        domains: @domains
      }

      MockK8s
      |> expect(:execute, fn [
                               %Operation{action: :get, resource: ^ns_k8s},
                               _,
                               _,
                               %Operation{action: :get, resource: deployment_resource}
                             ] ->
        assert deployment_resource == deployment_k8s
        {:ok, [ns_k8s, %{}, %{}, outdated_deployment]}
      end)
      |> expect(:execute, fn [%Operation{action: :update, resource: ^deployment_k8s}] ->
        {:ok, [deployment]}
      end)

      {:ok, upgraded: [^deployment]} = reconcile.(site)
    end

    test "creates missing wildcard virtual service", %{reconcile_1: reconcile} do
      vs = %VirtualService{
        name: @namespace,
        namespace: "affable",
        gateways: ["affable"],
        domains: @domains
      }

      vs_k8s = vs |> to_k8s

      MockK8s
      |> expect(:execute, fn outer_ops ->
        assert %Operation{action: :get, resource: vs_k8s} in outer_ops
        {:error, some_resources_missing: [vs]}
      end)
      |> expect(:execute, fn [%Operation{action: :create, resource: ^vs_k8s}] ->
        {:ok, []}
      end)

      {:ok, recreated: [^vs]} = reconcile.(%AffiliateSite{name: @namespace, domains: @domains})
    end
  end
end
