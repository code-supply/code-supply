defmodule SiteOperator.K8s do
  @callback execute([%SiteOperator.K8s.Operation{}]) :: {:ok, term} | {:error, term}
end
