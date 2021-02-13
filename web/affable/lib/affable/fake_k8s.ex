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

  def ready() do
    for site <- Site |> Repo.all() do
      IO.puts("FakeK8s: broadcasting for site #{site.internal_name}")

      PubSub.broadcast(
        :affable,
        site.internal_name,
        :site_ready
      )
    end
  end
end
