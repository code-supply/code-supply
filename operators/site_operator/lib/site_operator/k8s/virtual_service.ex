defmodule SiteOperator.K8s.VirtualService do
  @enforce_keys [:name, :domain]
  defstruct [:name, :domain]
end
