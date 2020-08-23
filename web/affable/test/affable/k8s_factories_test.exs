defmodule Affable.K8sFactoriesTest do
  use ExUnit.Case, async: true

  import Affable.K8sFactories

  test "affiliate site has correct name and domain names" do
    assert affiliate_site("some-name", ["example.com"]) == %{
             "apiVersion" => "site-operator.code.supply/v1",
             "kind" => "AffiliateSite",
             "metadata" => %{"name" => "some-name"},
             "spec" => %{"domains" => ["example.com"]}
           }
  end
end
