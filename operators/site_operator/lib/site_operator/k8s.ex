defmodule SiteOperator.K8s do
  @callback execute([%SiteOperator.K8s.Operation{}]) ::
              {:ok, term}
              | {:error, some_resources_missing: list(map())}
              | {:error, String.t()}
end
