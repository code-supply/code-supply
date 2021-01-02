defmodule SiteOperator.K8s.AuthorizationPolicy do
  @enforce_keys [:name, :namespace, :allow_all_from_namespaces, :allow_all_with_methods]
  defstruct [:name, :namespace, :allow_all_from_namespaces, :allow_all_with_methods]
end
