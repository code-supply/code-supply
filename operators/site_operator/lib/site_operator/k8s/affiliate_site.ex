defmodule SiteOperator.K8s.AffiliateSite do
  @enforce_keys [:name, :domains, :secret_key_base]
  defstruct [:name, :domains, :secret_key_base]
end
