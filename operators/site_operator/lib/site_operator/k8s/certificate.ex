defmodule SiteOperator.K8s.Certificate do
  @enforce_keys [:name, :domains]
  defstruct [:name, :domains]

  def secret_name(name) do
    "tls-#{name}"
  end
end
