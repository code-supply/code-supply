defmodule SiteOperator.AffiliateSite do
  @type namespace :: String.t()
  @type domain :: String.t()
  @callback create(namespace, domain) :: {:ok, term} | {:error, String.t()}
  @callback delete(namespace) :: {:ok, term} | {:error, String.t()}
end
