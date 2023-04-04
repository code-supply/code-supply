defmodule Hosting.FakeK8s do
  @behaviour Hosting.K8s

  @impl true
  def deploy(resource) do
    msg = "FakeK8s: would have deployed #{inspect(resource)}"
    {IO.puts(msg), msg}
  end

  @impl true
  def undeploy(resource) do
    msg = "FakeK8s: would have undeployed #{inspect(resource)}"
    {IO.puts(msg), msg}
  end

  @impl true
  def patch(resource) do
    msg = "FakeK8s: would have patched #{inspect(resource)}"
    {IO.puts(msg), msg}
  end
end
