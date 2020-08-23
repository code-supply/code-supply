defmodule SiteOperator.Controller.V1.AffiliateSiteTest do
  @moduledoc false
  use ExUnit.Case, async: true

  @moduletag capture_log: true
  import ExUnit.CaptureLog
  import Hammox

  alias SiteOperator.Controller.V1.AffiliateSite
  alias SiteOperator.MockAffiliateSite

  setup :verify_on_exit!

  describe "add/1" do
    setup do
      %{
        add: fn ->
          AffiliateSite.add(%{
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
      stub(MockAffiliateSite, :create, fn _, _ -> {:ok, ""} end)
      assert add.() == :ok
    end

    test "logs success", %{add: add} do
      stub(MockAffiliateSite, :create, fn _, _ -> {:ok, ""} end)
      assert capture_log(add) =~ "created"
    end

    test "creates the site", %{add: add} do
      expect(MockAffiliateSite, :create, fn "justatest", ["www.example.com"] ->
        {:ok, "some message"}
      end)

      add.()
    end

    test "returns :error on error", %{add: add} do
      stub(MockAffiliateSite, :create, fn _, _ -> {:error, ""} end)
      assert add.() == :error
    end

    test "logs failure", %{add: add} do
      stub(MockAffiliateSite, :create, fn _, _ -> {:error, "upstream error"} end)
      assert capture_log(add) =~ "upstream error"
    end
  end

  describe "modify/1" do
    test "returns :ok" do
      event = %{}
      result = AffiliateSite.modify(event)
      assert result == :ok
    end
  end

  describe "delete/1" do
    setup do
      %{delete: fn -> AffiliateSite.delete(%{"metadata" => %{"name" => "deleteme"}}) end}
    end

    test "returns :ok on success", %{delete: delete} do
      stub(MockAffiliateSite, :delete, fn _ -> {:ok, ""} end)
      assert delete.() == :ok
    end

    test "logs success", %{delete: delete} do
      stub(MockAffiliateSite, :delete, fn _ -> {:ok, ""} end)
      assert capture_log(delete) =~ "deleted"
    end

    test "deletes the site", %{delete: delete} do
      expect(MockAffiliateSite, :delete, fn "deleteme" -> {:ok, ""} end)
      delete.()
    end

    test "returns :error on error", %{delete: delete} do
      stub(MockAffiliateSite, :delete, fn _ -> {:error, ""} end)
      assert delete.() == :error
    end

    test "logs failure", %{delete: delete} do
      stub(MockAffiliateSite, :delete, fn _ -> {:error, "upstream error"} end)
      assert capture_log(delete) =~ "upstream error"
    end
  end

  describe "reconcile/1" do
    setup do
      %{
        reconcile: fn ->
          AffiliateSite.reconcile(%{
            "metadata" => %{"name" => "mysite"},
            "spec" => %{
              "domains" => ["www.example.com"]
            }
          })
        end,
        stub_error: fn ->
          stub(MockAffiliateSite, :reconcile, fn "mysite", ["www.example.com"] ->
            {:error, "upstream error"}
          end)
        end,
        stub_nothing_to_do: fn ->
          stub(MockAffiliateSite, :reconcile, fn "mysite", ["www.example.com"] ->
            {:ok, :nothing_to_do}
          end)
        end,
        stub_success: fn ->
          stub(MockAffiliateSite, :reconcile, fn "mysite", ["www.example.com"] ->
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
      expect(MockAffiliateSite, :reconcile, fn "mysite", ["www.example.com"] ->
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
