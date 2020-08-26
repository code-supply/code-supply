defmodule SiteOperator.K8s.Deployment do
  @enforce_keys [:name, :namespace, :image, :env_vars]
  defstruct [:name, :namespace, :image, :env_vars]
end
