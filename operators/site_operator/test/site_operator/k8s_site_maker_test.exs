defmodule SiteOperator.K8sSiteMakerTest do
  use ExUnit.Case, async: true

  alias SiteOperator.{K8sSiteMaker, SiteMaker, MockK8s}

  alias SiteOperator.K8s.{
    AffiliateSite,
    Deployment,
    Namespace,
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

  setup_all do
    Hammox.protect(K8sSiteMaker, SiteMaker)
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
      site = affiliate_site_no_custom_domain(name: @namespace)

      batch_1 = Operations.initial_creations(site |> from_k8s())
      batch_2 = Operations.inner_ns_creations(site |> from_k8s())

      MockK8s
      |> expect(:execute, fn ^batch_1 ->
        {:ok, %{}}
      end)
      |> expect(:execute, fn ^batch_2 ->
        {:ok, %{}}
      end)

      {:ok, _} = create.(site)
    end

    test "returns error when we get a k8s error", %{create_1: create} do
      MockK8s
      |> stub(:execute, fn _ ->
        {:error, ["Bad news"]}
      end)

      result = create.(affiliate_site_no_custom_domain(name: @namespace))

      assert elem(result, 0) == :error
      assert elem(result, 1) == ["Bad news"]
    end
  end

  describe "deletion" do
    test "deletes initial resources in parallel", %{delete_1: delete} do
      MockK8s
      |> expect(:execute, fn operations ->
        assert operations ==
                 Operations.deletions(affiliate_site_no_custom_domain(name: @namespace))

        {:ok, %{}}
      end)

      {:ok, %{}} = delete.(affiliate_site_no_custom_domain(name: @namespace))
    end

    test "returns error when we get a k8s error", %{delete_1: delete} do
      MockK8s
      |> stub(:execute, fn _ ->
        {:error, ["Bad news"]}
      end)

      assert {:error, ["Bad news"]} = delete.(affiliate_site_no_custom_domain(name: @namespace))
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
                             %Operation{action: :get}
                           ] ->
        {:ok, %{Deployment => [deployment()]}}
      end)

      assert reconcile.(%AffiliateSite{name: @namespace, domains: @domains}) ==
               {:ok, :nothing_to_do}
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
        {:ok, %{}}
      end)
      |> expect(:execute, fn ^expected_inner_operations ->
        {:ok, %{}}
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
                               %Operation{action: :get, resource: deployment_resource}
                             ] ->
        assert deployment_resource == deployment_k8s
        {:ok, %{Namespace => [ns_k8s], Deployment => [outdated_deployment]}}
      end)
      |> expect(:execute, fn [%Operation{action: :update, resource: ^deployment_k8s}] ->
        {:ok, %{Deployment => [deployment]}}
      end)

      {:ok, upgraded: [^deployment]} = reconcile.(site)
    end

    test "copes with missing deployment when namespace deleted", %{reconcile_1: reconcile} do
      ns = %Namespace{name: @namespace}
      ns_k8s = ns |> to_k8s

      deployment = deployment()
      deployment_k8s = deployment |> to_k8s

      site = %AffiliateSite{
        name: @namespace,
        domains: @domains
      }

      expected_inner_operations = Operations.inner_ns_creations(site |> from_k8s())

      MockK8s
      |> expect(:execute, fn [
                               %Operation{action: :get, resource: ^ns_k8s},
                               _,
                               %Operation{action: :get, resource: ^deployment_k8s}
                             ] ->
        {:error, some_resources_missing: [ns, deployment]}
      end)
      |> expect(:execute, fn [%Operation{action: :create, resource: ^ns_k8s}] ->
        {:ok, %{Namespace => [ns]}}
      end)
      |> expect(:execute, fn ^expected_inner_operations ->
        {:ok, %{}}
      end)

      {:ok, recreated: [^ns, ^deployment]} = reconcile.(site)
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
        {:ok, %{}}
      end)

      {:ok, recreated: [^vs]} = reconcile.(%AffiliateSite{name: @namespace, domains: @domains})
    end
  end
end
