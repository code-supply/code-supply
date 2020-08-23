defmodule Affable.RealK8s do
  def deploy(resource) do
    run(K8s.Client.create(resource))
  end

  def undeploy(resource) do
    run(K8s.Client.delete(resource))
  end

  defp run(operation) do
    {:ok, conn} = K8s.Conn.lookup(:default)
    K8s.Client.run(operation, conn)
  end
end
