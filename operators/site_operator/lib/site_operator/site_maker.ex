defmodule SiteOperator.SiteMaker do
  alias SiteOperator.K8s.AffiliateSite

  @type namespace :: String.t()
  @type domain :: String.t()
  @type secret_key_base :: String.t()
  @callback create(%AffiliateSite{}) :: {:ok, term} | {:error, String.t()}
  @callback delete(namespace) :: {:ok, term} | {:error, String.t()}
  @callback reconcile(%AffiliateSite{}) ::
              {:ok, recreated: list(map())}
              | {:ok, :nothing_to_do}
              | {:error, String.t()}
end
