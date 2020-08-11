defmodule SiteOperator.K8s.Certificate do
  @enforce_keys [:name, :domains]
  defstruct [:name, :domains]
end
