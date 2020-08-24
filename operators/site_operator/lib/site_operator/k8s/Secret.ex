defmodule SiteOperator.K8s.Secret do
  @enforce_keys [:name, :namespace, :data]
  defstruct [:name, :namespace, :data]
end
