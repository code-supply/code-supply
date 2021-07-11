defmodule SiteOperator.K8sSiteMakerTest do
  use ExUnit.Case, async: true

  alias SiteOperator.{K8sSiteMaker, SiteMaker, MockK8s}
  alias SiteOperator.PhoenixSites.PhoenixSite

  alias SiteOperator.K8s.{
    AffiliateSite,
    Certificate,
    Deployment,
    Gateway,
    Ingress,
    Namespace,
    Operation,
    Operations,
    VirtualService
  }

  import SiteOperator.K8s.Conversions
  import SiteOperator.AffiliateSiteFixtures

  import Hammox

  @namespace "sited3adb33f"
  @domains ["sited3adb33f.affable.app"]

  setup :verify_on_exit!

  setup_all do
    Hammox.protect(K8sSiteMaker, SiteMaker)
  end

  defp affiliate_site(extra_domains \\ []) do
    %AffiliateSite{
      name: @namespace,
      domains: @domains ++ extra_domains
    }
  end

  defp deployment(affiliate_site) do
    affiliate_site |> from_k8s() |> Operations.deployment()
  end

  defp virtual_service(affiliate_site) do
    affiliate_site |> from_k8s() |> Operations.virtual_service()
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
                 Operations.deletions(
                   affiliate_site_no_custom_domain(name: @namespace)
                   |> from_k8s()
                 )

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

  describe "reconciliation of site with custom domains" do
    test "creates missing certificates", %{reconcile_1: reconcile} do
      site = %AffiliateSite{
        name: @namespace,
        domains: ["something.affable.app", "acoolcustomdomain.example.com"]
      }

      expected_certificate = %Certificate{name: "something", domains: site.domains}
      expected_certificate_k8s = expected_certificate |> to_k8s()

      MockK8s
      |> expect_custom_domain_checks(fn ->
        {:error, some_resources_missing: [expected_certificate]}
      end)
      |> expect(:execute, fn [%Operation{action: :create, resource: ^expected_certificate_k8s}] ->
        {:ok, %{}}
      end)

      assert {:ok, recreated: [expected_certificate]} == reconcile.(site)
    end

    test "refers to TLS secret from load balancer", %{reconcile_1: reconcile} do
      site = %AffiliateSite{
        name: @namespace,
        domains: ["something.affable.app", "acoolcustomdomain.example.com"]
      }

      ingress_for_retrieval = %Ingress{name: "load-balancer-affable", tls_secret_names: []}
      ingress_for_retrieval_k8s = ingress_for_retrieval |> to_k8s()

      existing_ingress = %{
        ingress_for_retrieval
        | tls_secret_names: ["affable-www", "dont-touch"]
      }

      expected_ingress = %{
        existing_ingress
        | tls_secret_names: ["affable-www", "dont-touch", "tls-#{@namespace}"]
      }

      expected_ingress_k8s = expected_ingress |> to_k8s()

      MockK8s
      |> expect_custom_domain_checks(fn ->
        {:ok, %{}}
      end)
      |> expect(:execute, fn [%Operation{action: :get, resource: ^ingress_for_retrieval_k8s}] ->
        {:ok, %{Ingress => [existing_ingress]}}
      end)
      |> expect(:execute, fn [%Operation{action: :update, resource: ^expected_ingress_k8s}] ->
        {:ok, %{}}
      end)

      assert {:ok, upgraded: [expected_ingress]} == reconcile.(site)
    end

    test "creates missing gateway", %{reconcile_1: reconcile} do
      site = %AffiliateSite{
        name: @namespace,
        domains: ["something.affable.app", "acoolcustomdomain.example.com"]
      }

      expected_gateway = %Gateway{name: "app", namespace: @namespace, domains: site.domains}
      expected_gateway_k8s = expected_gateway |> to_k8s()

      MockK8s
      |> expect_custom_domain_checks(fn ->
        {:error, some_resources_missing: [expected_gateway]}
      end)
      |> expect(:execute, fn [%Operation{action: :create, resource: ^expected_gateway_k8s}] ->
        {:ok, %{}}
      end)

      assert {:ok, recreated: [expected_gateway]} == reconcile.(site)
    end

    test "adds gateway to the virtual service", %{reconcile_1: reconcile} do
      outdated_site = affiliate_site()
      site = affiliate_site(["acoolcustomdomain.example.com"])

      outdated_virtual_service = outdated_site |> virtual_service()

      virtual_service = site |> virtual_service()
      virtual_service_k8s = virtual_service |> to_k8s()

      deployment = site |> deployment()

      ingress = %Ingress{name: "ignore", tls_secret_names: ["tls-#{@namespace}"]}

      MockK8s
      |> expect_custom_domain_checks(fn ->
        {:ok,
         %{
           Deployment => [deployment],
           VirtualService => [outdated_virtual_service]
         }}
      end)
      |> expect(:execute, fn [
                               %Operation{
                                 action: :update,
                                 resource: ^virtual_service_k8s
                               }
                             ] ->
        {:ok, %{VirtualService => [virtual_service]}}
      end)
      |> expect(:execute, fn [%Operation{action: :get}] ->
        {:ok, %{Ingress => [ingress]}}
      end)

      assert {:ok, upgraded: [^virtual_service | _]} = reconcile.(site)
    end

    test "provides useful info when upgrading virtual service doesn't work", %{
      reconcile_1: reconcile
    } do
      outdated_site = affiliate_site()
      site = affiliate_site(["acoolcustomdomain.example.com"])

      outdated_virtual_service = outdated_site |> virtual_service()

      virtual_service = site |> virtual_service()
      virtual_service_k8s = virtual_service |> to_k8s()

      deployment = site |> deployment()

      MockK8s
      |> expect_custom_domain_checks(fn ->
        {:ok,
         %{
           Deployment => [deployment],
           VirtualService => [outdated_virtual_service]
         }}
      end)
      |> expect(:execute, fn [
                               %Operation{
                                 action: :update,
                                 resource: ^virtual_service_k8s
                               }
                             ] ->
        {:error, ["bad news"]}
      end)

      assert {:error,
              upgrade_failed: [
                original: ^outdated_virtual_service,
                proposed: ^virtual_service,
                proposed_phoenix_site: %PhoenixSite{},
                messages: ["bad news"]
              ]} = reconcile.(site)
    end
  end

  describe "regular reconciliation" do
    test "does nothing when the top-level resources are available with insignificant differences",
         %{
           reconcile_1: reconcile
         } do
      site = affiliate_site()

      MockK8s
      |> stub(:execute, fn [
                             %Operation{action: :get},
                             %Operation{action: :get},
                             %Operation{action: :get}
                           ] ->
        {:ok,
         %{Deployment => [site |> deployment()], VirtualService => [site |> virtual_service()]}}
      end)

      assert reconcile.(site) ==
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

      site = affiliate_site()

      deployment = site |> deployment()
      deployment_k8s = deployment |> to_k8s

      outdated_deployment = %{deployment | image: "old-image"}

      MockK8s
      |> expect(:execute, fn [
                               %Operation{action: :get, resource: ^ns_k8s},
                               %Operation{action: :get},
                               %Operation{action: :get, resource: sent_deployment_k8s}
                             ] ->
        assert sent_deployment_k8s == deployment_k8s

        {:ok,
         %{
           Namespace => [ns_k8s],
           Deployment => [outdated_deployment],
           VirtualService => [site |> virtual_service()]
         }}
      end)
      |> expect(:execute, fn [%Operation{action: :update, resource: ^deployment_k8s}] ->
        {:ok, %{Deployment => [deployment]}}
      end)

      {:ok, upgraded: [^deployment]} = reconcile.(site)
    end

    test "copes with missing deployment when namespace deleted", %{reconcile_1: reconcile} do
      ns = %Namespace{name: @namespace}
      ns_k8s = ns |> to_k8s

      deployment = affiliate_site() |> deployment()
      deployment_k8s = deployment |> to_k8s

      site = %AffiliateSite{
        name: @namespace,
        domains: @domains
      }

      expected_inner_operations = Operations.inner_ns_creations(site |> from_k8s())

      MockK8s
      |> expect(:execute, fn [
                               %Operation{action: :get, resource: ^ns_k8s},
                               %Operation{action: :get},
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

    defp expect_custom_domain_checks(mock_k8s, f) do
      mock_k8s
      |> expect(:execute, fn [
                               %Operation{action: :get},
                               %Operation{action: :get},
                               %Operation{action: :get},
                               %Operation{action: :get},
                               %Operation{action: :get}
                             ] ->
        f.()
      end)
    end
  end
end
