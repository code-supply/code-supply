defmodule Affiliate.RealHTTPTest do
  use ExUnit.Case, async: true

  @moduletag :external

  setup_all do
    Hammox.protect(Affiliate.RealHTTP, Affiliate.HTTP)
  end

  test "successful GET provides a deserialised response", %{get_1: get} do
    {:ok, resp} = get.("https://httpbin.org/json")

    assert %{"slideshow" => %{"author" => "Yours Truly"}} = resp
  end

  test "unsuccessful GET gives us the status code", %{get_1: get} do
    assert {:error, %{code: 404, message: ""}} = get.("https://httpbin.org/status/404")
  end
end
