defmodule Affable.K8s do
  @type domain_name :: String.t()
  @callback deploy(domain_name :: domain_name) :: {:ok, term} | {:error, String.t()}
  @callback undeploy(domain_name :: domain_name) :: {:ok, term} | {:error, String.t()}
end
