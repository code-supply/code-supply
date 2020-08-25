defmodule SiteOperator.K8s.Deployment do
  @enforce_keys [:name, :namespace, :env_vars]
  defstruct [:name, :namespace, :env_vars]
end
