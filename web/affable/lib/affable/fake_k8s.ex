defmodule Affable.FakeK8s do
  @behaviour Affable.K8s

  @impl true
  def deploy(resource) do
    IO.puts("FakeK8s: would have deployed #{inspect(resource)}")
  end

  @impl true
  def undeploy(resource) do
    IO.puts("FakeK8s: would have undeployed #{inspect(resource)}")
  end
end
