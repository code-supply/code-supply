defmodule SiteOperator.RealK8s do
  @behaviour SiteOperator.K8s

  import SiteOperator.K8s.Conversions, only: [from_k8s: 1]

  @impl SiteOperator.K8s
  def execute(operations) do
    third_party_ops =
      operations
      |> Enum.map(fn op ->
        case op do
          %SiteOperator.K8s.Operation{action: :get, resource: resource} ->
            K8s.Client.get(resource)

          %SiteOperator.K8s.Operation{action: :create, resource: resource} ->
            K8s.Client.create(resource)

          %SiteOperator.K8s.Operation{action: :delete, resource: resource} ->
            K8s.Client.delete(resource)
        end
      end)

    results = K8s.Client.parallel(third_party_ops, cluster_name(), [])

    if Enum.all?(results, &match?({:ok, _}, &1)) do
      {:ok, results |> Enum.map(fn {:ok, body} -> handle_body(body) end)}
    else
      handle_errors(error_pairs(operations, results))
    end
  end

  defp handle_errors(errors) do
    case missing_resources(errors) do
      [] ->
        {:error, errors}

      missing ->
        {:error, some_resources_missing: missing}
    end
  end

  defp error_pairs(operations, results) do
    List.zip([operations, results])
    |> Enum.filter(fn {_op, result} ->
      elem(result, 0) == :error
    end)
  end

  defp missing_resources(errors) do
    errors
    |> Enum.filter(&match?({%SiteOperator.K8s.Operation{}, {:error, :not_found}}, &1))
    |> Enum.map(fn {%SiteOperator.K8s.Operation{resource: resource}, _result} ->
      from_k8s(resource)
    end)
  end

  defp handle_body(%{"details" => _}) do
    ""
  end

  defp handle_body(%{"metadata" => _} = body) do
    from_k8s(body)
  end

  defp cluster_name do
    Application.get_env(:bonny, :cluster_name)
  end
end
