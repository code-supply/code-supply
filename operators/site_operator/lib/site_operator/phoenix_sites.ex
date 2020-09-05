defmodule SiteOperator.PhoenixSites do
  alias SiteOperator.K8s.AffiliateSite
  alias SiteOperator.PhoenixSites.PhoenixSite

  def from_k8s(%AffiliateSite{} = site) do
    %PhoenixSite{
      name: site.name,
      domains: site.domains,
      image: affiliate_site_image(),
      secret_key_base: generate_secret_key(),
      distribution_cookie: distribution_cookie()
    }
  end

  defp affiliate_site_image do
    Application.get_env(:site_operator, :affiliate_site_image)
  end

  defp distribution_cookie do
    Application.get_env(:site_operator, :distribution_cookie)
  end

  defp generate_secret_key do
    case Application.get_env(:site_operator, :secret_key_generator) do
      :generate ->
        length = 64
        :crypto.strong_rand_bytes(length) |> Base.encode64() |> binary_part(0, length)

      value ->
        value
    end
  end
end
