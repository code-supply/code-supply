defmodule SiteOperator.K8s.VirtualService do
  @enforce_keys [:name, :namespace, :gateways, :domains]
  defstruct [:name, :namespace, :gateways, :domains]
end
