defmodule SiteOperator.K8s.VirtualService do
  @enforce_keys [:name, :domains]
  defstruct [:name, :domains]
end
