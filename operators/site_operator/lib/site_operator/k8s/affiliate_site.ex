defmodule SiteOperator.K8s.AffiliateSite do
  @enforce_keys [:name, :domains, :secret_key_base, :distribution_cookie]
  defstruct [:name, :domains, :secret_key_base, :distribution_cookie]
end
