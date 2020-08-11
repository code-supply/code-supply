defmodule SiteOperator.K8s.Gateway do
  @enforce_keys [:name, :domain]
  defstruct [:name, :domain]
end
