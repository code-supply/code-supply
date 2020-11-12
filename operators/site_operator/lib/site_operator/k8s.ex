defmodule SiteOperator.K8s do
  @callback execute([%SiteOperator.K8s.Operation{}]) ::
              {:ok, list(term)}
              | {:error, some_resources_missing: list(struct())}
              | {:error, list(term)}
end
