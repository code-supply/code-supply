defmodule SiteOperator.K8s.Secret do
  @enforce_keys [:name, :data]
  defstruct [:name, :data]
end
