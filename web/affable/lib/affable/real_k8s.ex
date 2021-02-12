defmodule Affable.RealK8s do
  @behaviour Affable.K8s

  @impl true
  def deploy(resource) do
    case run(K8s.Client.create(resource)) do
      {:ok, _} = result ->
        result

      {:error, e} ->
        {:error, "#{inspect(e)}"}
    end
  end

  @impl true
  def undeploy(resource) do
    run(K8s.Client.delete(resource))
  end

  defp run(operation) do
    {:ok, conn} = K8s.Conn.lookup(:default)
    K8s.Client.run(operation, conn)
  end
end
