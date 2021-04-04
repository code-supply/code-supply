defmodule Affable.K8sFactories do
  alias Affable.Sites.Site

  def affiliate_site(%Site{domains: domains, internal_name: internal_name}) do
    affiliate_site(internal_name, Enum.map(domains, & &1.name))
  end

  def affiliate_site(%Site{domains: domains, internal_name: internal_name}, new_domain_name) do
    affiliate_site(internal_name, [new_domain_name | Enum.map(domains, & &1.name)])
  end

  def affiliate_site(name, domains) do
    %{
      "apiVersion" => "site-operator.code.supply/v1",
      "kind" => "AffiliateSite",
      "metadata" => %{"name" => name},
      "spec" => %{"domains" => domains}
    }
  end
end
