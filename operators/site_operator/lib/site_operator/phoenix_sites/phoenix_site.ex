defmodule SiteOperator.PhoenixSites.PhoenixSite do
  @keys [:name, :image, :domains, :secret_key_base, :live_view_signing_salt]
  @enforce_keys @keys
  defstruct @keys
end
