defmodule SiteOperator.SiteMaker do
  alias SiteOperator.K8s.{AffiliateSite, Operation}

  @type namespace :: String.t()
  @type domain :: String.t()
  @type secret_key_base :: String.t()
  @type batch :: list(%Operation{})
  @callback create(list(batch)) :: {:ok, term} | {:error, String.t()}
  @callback delete(%AffiliateSite{}) :: {:ok, term} | {:error, String.t()}
  @callback reconcile(%AffiliateSite{}) ::
              {:ok, recreated: list(map())}
              | {:ok, upgraded: list(map())}
              | {:ok, :nothing_to_do}
              | {:error, String.t()}
end
