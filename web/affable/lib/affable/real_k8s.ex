defmodule Affable.RealK8s do
  @behaviour Affable.K8s

  @impl true
  def deploy(resource) do
    run(K8s.Client.create(resource))
  end

  @impl true
  def undeploy(resource) do
    run(K8s.Client.delete(resource))
  end

  @impl true
  def patch(resource) do
    run(K8s.Client.patch(resource))
  end

  defp run(operation) do
    {:ok, conn} = K8s.Conn.lookup(:default)

    case K8s.Client.run(operation, conn) do
      {:ok, _} = result ->
        result

      {:error, e} ->
        {:error, "#{inspect(e)}"}
    end
  end
end
