defmodule SiteOperator.AffiliateSite do
  @type namespace :: String.t()
  @type domain :: String.t()
  @type secret_key_base :: String.t()
  @callback create(namespace, list(domain), secret_key_base) :: {:ok, term} | {:error, String.t()}
  @callback delete(namespace) :: {:ok, term} | {:error, String.t()}
  @callback reconcile(namespace, list(domain), secret_key_base) ::
              {:ok, recreated: list(map())}
              | {:ok, :nothing_to_do}
              | {:error, String.t()}
end
