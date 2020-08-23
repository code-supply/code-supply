defmodule Affable.K8sFactories do
  def affiliate_site(name, domains) do
    %{
      "apiVersion" => "site-operator.code.supply/v1",
      "kind" => "AffiliateSite",
      "metadata" => %{"name" => name},
      "spec" => %{"domains" => domains}
    }
  end
end
