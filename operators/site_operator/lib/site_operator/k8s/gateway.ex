defmodule SiteOperator.K8s.Gateway do
  @enforce_keys [:name, :namespace, :domains]
  defstruct [:name, :namespace, :domains]
end
