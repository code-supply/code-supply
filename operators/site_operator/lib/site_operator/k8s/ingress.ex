defmodule SiteOperator.K8s.Ingress do
  alias SiteOperator.K8s.Certificate

  @enforce_keys [:name, :tls_secret_names]
  defstruct [:name, :tls_secret_names]

  def add_secret(%SiteOperator.K8s.Ingress{} = ingress, site_name) do
    Map.update(ingress, :tls_secret_names, [], &(&1 ++ [Certificate.secret_name(site_name)]))
  end
end
