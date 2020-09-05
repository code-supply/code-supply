defmodule SiteOperator.AffiliateSiteFixtures do
  alias SiteOperator.K8s.AffiliateSite

  def affiliate_site_no_custom_domain(name: name) do
    %AffiliateSite{
      name: name,
      domains: ["site123.affable.app"]
    }
  end
end
