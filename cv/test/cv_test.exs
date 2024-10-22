defmodule CvTest do
  use ExUnit.Case
  doctest Cv

  test "greets the world" do
    assert Cv.hello() == :world
  end
end
