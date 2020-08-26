defmodule SiteOperator.Controller.V1.AffiliateSiteTest do
  @moduledoc false
  use ExUnit.Case, async: true

  @moduletag capture_log: true
  import ExUnit.CaptureLog
  import Hammox

  alias SiteOperator.Controller
  alias SiteOperator.K8s.AffiliateSite
  alias SiteOperator.MockSiteMaker

  setup :verify_on_exit!

  describe "add/1" do
    setup do
      %{
        add: fn ->
          Controller.V1.AffiliateSite.add(%{
            "apiVersion" => "site-operator.code.supply/v1alpha1",
            "kind" => "AffiliateSite",
            "metadata" => %{"name" => "justatest"},
            "spec" => %{
              "domains" => ["www.example.com"]
            }
          })
        end
      }
    end

    test "returns :ok on success", %{add: add} do
      stub(MockSiteMaker, :create, fn _ -> {:ok, ""} end)
      assert add.() == :ok
    end

    test "logs success", %{add: add} do
      stub(MockSiteMaker, :create, fn _ -> {:ok, ""} end)
      assert capture_log(add) =~ "created"
    end

    test "creates the site", %{add: add} do
      expected_cookie = Application.get_env(:site_operator, :distribution_cookie)
      expected_image = Application.get_env(:site_operator, :affiliate_site_image)

      expect(MockSiteMaker, :create, fn %AffiliateSite{
                                          name: "justatest",
                                          image: ^expected_image,
                                          domains: ["www.example.com"],
                                          secret_key_base: _,
                                          distribution_cookie: ^expected_cookie
                                        } ->
        {:ok, "some message"}
      end)

      add.()
    end

    test "returns :error on error", %{add: add} do
      stub(MockSiteMaker, :create, fn _ -> {:error, ""} end)
      assert add.() == :error
    end

    test "logs failure", %{add: add} do
      stub(MockSiteMaker, :create, fn _ -> {:error, "upstream error"} end)
      assert capture_log(add) =~ "upstream error"
    end
  end

  describe "modify/1" do
    test "returns :ok" do
      event = %{}
      result = Controller.V1.AffiliateSite.modify(event)
      assert result == :ok
    end
  end

  describe "delete/1" do
    setup do
      %{
        delete: fn ->
          Controller.V1.AffiliateSite.delete(%{"metadata" => %{"name" => "deleteme"}})
        end
      }
    end

    test "returns :ok on success", %{delete: delete} do
      stub(MockSiteMaker, :delete, fn _ -> {:ok, ""} end)
      assert delete.() == :ok
    end

    test "logs success", %{delete: delete} do
      stub(MockSiteMaker, :delete, fn _ -> {:ok, ""} end)
      assert capture_log(delete) =~ "deleted"
    end

    test "deletes the site", %{delete: delete} do
      expect(MockSiteMaker, :delete, fn "deleteme" -> {:ok, ""} end)
      delete.()
    end

    test "returns :error on error", %{delete: delete} do
      stub(MockSiteMaker, :delete, fn _ -> {:error, ""} end)
      assert delete.() == :error
    end

    test "logs failure", %{delete: delete} do
      stub(MockSiteMaker, :delete, fn _ -> {:error, "upstream error"} end)
      assert capture_log(delete) =~ "upstream error"
    end
  end

  describe "reconcile/1" do
    setup do
      expected_cookie = Application.get_env(:site_operator, :distribution_cookie)

      %{
        reconcile: fn ->
          Controller.V1.AffiliateSite.reconcile(%{
            "metadata" => %{"name" => "mysite"},
            "spec" => %{
              "domains" => ["www.example.com"]
            }
          })
        end,
        stub_error: fn ->
          stub(MockSiteMaker, :reconcile, fn %AffiliateSite{
                                               name: "mysite",
                                               domains: ["www.example.com"],
                                               secret_key_base: _secret_key_base,
                                               distribution_cookie: ^expected_cookie
                                             } ->
            {:error, "upstream error"}
          end)
        end,
        stub_nothing_to_do: fn ->
          stub(MockSiteMaker, :reconcile, fn %AffiliateSite{
                                               name: "mysite",
                                               domains: ["www.example.com"],
                                               secret_key_base: _secret_key_base,
                                               distribution_cookie: ^expected_cookie
                                             } ->
            {:ok, :nothing_to_do}
          end)
        end,
        stub_success: fn ->
          stub(MockSiteMaker, :reconcile, fn %AffiliateSite{
                                               name: "mysite",
                                               domains: ["www.example.com"],
                                               secret_key_base: _secret_key_base,
                                               distribution_cookie: ^expected_cookie
                                             } ->
            {:ok, recreated: [%SiteOperator.K8s.Namespace{name: "mysite"}]}
          end)
        end
      }
    end

    test "returns :ok", %{reconcile: reconcile, stub_success: stub} do
      stub.()
      result = reconcile.()
      assert result == :ok
    end

    test "logs success with nothing to do", %{reconcile: reconcile, stub_nothing_to_do: stub} do
      stub.()
      assert capture_log(reconcile) =~ "nothing to do"
    end

    test "reconciles", %{reconcile: reconcile} do
      expect(MockSiteMaker, :reconcile, fn %AffiliateSite{
                                             name: "mysite",
                                             domains: ["www.example.com"],
                                             secret_key_base: _secret_key_base
                                           } ->
        {:ok, recreated: [%SiteOperator.K8s.Namespace{name: "therightone"}]}
      end)

      reconcile.()
    end

    test "logs successful reconciliation", %{reconcile: reconcile, stub_success: stub} do
      stub.()
      logs = capture_log(reconcile)
      assert logs =~ "reconciled"
    end

    test "returns :error on error", %{reconcile: reconcile, stub_error: stub} do
      stub.()
      assert reconcile.() == :error
    end

    test "logs failure", %{reconcile: reconcile, stub_error: stub} do
      stub.()
      assert capture_log(reconcile) =~ "upstream error"
    end
  end
end
