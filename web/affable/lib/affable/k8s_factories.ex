defmodule Affable.K8sFactories do
  def affiliate_site(domain_name) do
    %{
      "apiVersion" => "site-operator.code.supply/v1",
      "kind" => "AffiliateSite",
      "metadata" => %{"name" => String.replace(domain_name, ".", "-")},
      "spec" => %{"domain" => domain_name}
    }
  end
end
