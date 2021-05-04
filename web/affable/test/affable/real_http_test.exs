defmodule Affable.RealHTTPTest do
  use ExUnit.Case, async: true

  @moduletag :external

  setup_all do
    Hammox.protect(Affable.RealHTTP, Affable.HTTP)
  end

  test "HEAD reports success", %{head_1: head} do
    assert :ok = head.("https://httpbin.org/get")
  end

  test "HEAD reports failure", %{head_1: head} do
    assert {:error, {:tls_alert, _}} = head.("https://self-signed.badssl.com/")
  end

  test "successful PUT includes a deserialised response", %{put_2: put} do
    {:ok, resp} = put.(%{"hi" => "you", how: "are-you-doing"}, "https://httpbin.org/put")

    assert resp["headers"]["Content-Type"] == "application/json"

    assert resp["json"] == %{
             "hi" => "you",
             "how" => "are-you-doing"
           }
  end

  test "unsuccessful PUT gives us the status code", %{put_2: put} do
    assert {:error, %{code: 404, message: ""}} =
             put.(
               %{"hi" => "you", how: "are-you-doing"},
               "https://httpbin.org/status/404"
             )
  end
end
