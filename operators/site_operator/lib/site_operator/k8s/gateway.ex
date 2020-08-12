defmodule SiteOperator.K8s.Gateway do
  @enforce_keys [:name, :domains]
  defstruct [:name, :domains]
end
