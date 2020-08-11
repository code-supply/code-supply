defmodule SiteOperator.K8s.Namespace do
  @enforce_keys [:name]
  defstruct [:name]
end
