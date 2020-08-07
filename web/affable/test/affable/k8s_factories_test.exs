defmodule Affable.K8sFactoriesTest do
  use ExUnit.Case, async: true

  import Affable.K8sFactories

  test "affiliate site has correct name and domain name" do
    assert affiliate_site("example.com") == %{
             "apiVersion" => "site-operator.code.supply/v1",
             "kind" => "AffiliateSite",
             "metadata" => %{"name" => "example-com"},
             "spec" => %{"domain" => "example.com"}
           }
  end
end
