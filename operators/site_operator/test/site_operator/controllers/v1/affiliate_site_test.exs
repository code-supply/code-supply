defmodule SiteOperator.Controller.V1.AffiliateSiteTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import Hammox
  alias SiteOperator.Controller.V1.AffiliateSite
  alias SiteOperator.MockAffiliateSite

  setup :verify_on_exit!

  describe "add/1" do
    test "creates the site and returns :ok" do
      expect(MockAffiliateSite, :create, fn ns, domain ->
        assert ns == "justatest"
        assert domain == "www.example.com"
        {:ok, "some message"}
      end)

      result =
        AffiliateSite.add(%{
          "apiVersion" => "site-operator.code.supply/v1alpha1",
          "kind" => "AffiliateSite",
          "metadata" => %{"name" => "justatest"},
          "spec" => %{
            "domain" => "www.example.com"
          }
        })

      assert result == :ok
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
    test "returns :ok" do
      event = %{}
      result = AffiliateSite.delete(event)
      assert result == :ok
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
