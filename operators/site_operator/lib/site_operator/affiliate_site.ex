defmodule SiteOperator.AffiliateSite do
  @type namespace :: String.t()
  @callback create(namespace) :: {:ok, term} | {:error, String.t()}
  @callback delete(namespace) :: {:ok, term} | {:error, :not_found}
end
