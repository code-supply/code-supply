defmodule SiteOperator.K8s.AffiliateSite do
  @enforce_keys [:name, :domains]
  defstruct [:name, :domains]
end
