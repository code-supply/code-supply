defmodule Hosting.K8s do
  @type resource :: map()
  @callback deploy(resource) :: {:ok, term} | {:error, String.t()}
  @callback undeploy(resource) :: {:ok, term} | {:error, String.t()}
  @callback patch(resource) :: {:ok, term} | {:error, String.t()}
end
