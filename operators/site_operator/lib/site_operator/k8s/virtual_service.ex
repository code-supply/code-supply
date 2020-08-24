defmodule SiteOperator.K8s.VirtualService do
  @enforce_keys [:name, :namespace, :domains]
  defstruct [:name, :namespace, :domains]
end
