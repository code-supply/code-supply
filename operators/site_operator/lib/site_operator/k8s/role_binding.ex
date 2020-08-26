defmodule SiteOperator.K8s.RoleBinding do
  @enforce_keys [:name, :namespace, :role_kind, :role_name, :subjects]
  defstruct [:name, :namespace, :role_kind, :role_name, :subjects]
end
