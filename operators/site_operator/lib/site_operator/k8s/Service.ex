defmodule SiteOperator.K8s.Service do
  @enforce_keys [:name, :namespace]
  defstruct [:name, :namespace]
end
