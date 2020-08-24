defmodule SiteOperator.K8s.Deployment do
  @enforce_keys [:name, :namespace]
  defstruct [:name, :namespace]
end
