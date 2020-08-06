defmodule SiteOperator.Controller.V1.AffiliateSiteTest do
  @moduledoc false
  use ExUnit.Case, async: true
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
              "domain" => "www.example.com"
            }
          })
        end
      }
    end

    test "returns :ok on success", %{add: add} do
      stub(MockAffiliateSite, :create, fn _, _ -> {:ok, ""} end)
      assert add.() == :ok
    end

    test "creates the site", %{add: add} do
      expect(MockAffiliateSite, :create, fn "justatest", "www.example.com" ->
        {:ok, "some message"}
      end)

      add.()
    end

    test "returns :error on error", %{add: add} do
      stub(MockAffiliateSite, :create, fn _, _ -> {:error, ""} end)
      assert add.() == :error
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

    test "deletes the site", %{delete: delete} do
      expect(MockAffiliateSite, :delete, fn "deleteme" -> {:ok, ""} end)
      delete.()
    end

    test "returns :error on error", %{delete: delete} do
      stub(MockAffiliateSite, :delete, fn _ -> {:error, ""} end)
      assert delete.() == :error
    end
  end

  describe "reconcile/1" do
    test "returns :ok" do
      event = %{}
      result = AffiliateSite.reconcile(event)
      assert result == :ok
    end
  end
end
