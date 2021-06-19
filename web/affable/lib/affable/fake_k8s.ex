defmodule Affable.FakeK8s do
  @behaviour Affable.K8s

  alias Affable.Repo
  alias Affable.Sites.Site
  alias Phoenix.PubSub

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
