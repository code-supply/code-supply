defmodule SiteOperator.SiteMaker do
  alias SiteOperator.K8s.{AffiliateSite, Operation}

  @type namespace :: String.t()
  @type domain :: String.t()
  @type secret_key_base :: String.t()
  @type batch :: list(%Operation{})
  @callback create(list(batch)) :: {:ok, term} | {:error, list(term)}
  @callback delete(%AffiliateSite{}) :: {:ok, term} | {:error, list(term)}
  @callback reconcile(%AffiliateSite{}) ::
              {:ok, recreated: list(map())}
              | {:ok, upgraded: list(map())}
              | {:ok, :nothing_to_do}
              | {:error, list(term)}
end
