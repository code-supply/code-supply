defmodule SiteOperatorTest do
  use ExUnit.Case
  doctest SiteOperator

  test "greets the world" do
    assert SiteOperator.hello() == :world
  end
end
