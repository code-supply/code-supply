defmodule SiteOperator.K8s.Operation do
  @enforce_keys [:action, :resource]
  defstruct [:action, :resource]
end
