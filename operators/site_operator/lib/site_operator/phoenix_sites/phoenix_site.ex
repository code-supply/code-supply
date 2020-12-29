defmodule SiteOperator.PhoenixSites.PhoenixSite do
  @enforce_keys [:name, :image, :domains, :secret_key_base]
  defstruct [:name, :image, :domains, :secret_key_base]
end
