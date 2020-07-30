defmodule SiteOperator.Controller.V1.SiteTest do
  @moduledoc false
  use ExUnit.Case, async: false
  alias SiteOperator.Controller.V1.Site

  describe "add/1" do
    test "returns :ok" do
      event = %{}
      result = Site.add(event)
      assert result == :ok
    end
  end

  describe "modify/1" do
    test "returns :ok" do
      event = %{}
      result = Site.modify(event)
      assert result == :ok
    end
  end

  describe "delete/1" do
    test "returns :ok" do
      event = %{}
      result = Site.delete(event)
      assert result == :ok
    end
  end

  describe "reconcile/1" do
    test "returns :ok" do
      event = %{}
      result = Site.reconcile(event)
      assert result == :ok
    end
  end
end
