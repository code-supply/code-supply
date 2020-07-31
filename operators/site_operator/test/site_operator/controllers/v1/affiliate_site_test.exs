defmodule SiteOperator.Controller.V1.AffiliateSiteTest do
  @moduledoc false
  use ExUnit.Case, async: false
  alias SiteOperator.Controller.V1.AffiliateSite

  describe "add/1" do
    test "returns :ok" do
      event = %{}
      result = AffiliateSite.add(event)
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
