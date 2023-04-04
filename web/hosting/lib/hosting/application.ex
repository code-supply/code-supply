defmodule Hosting.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children =
      [
        # Start the Ecto repository
        Hosting.Repo,
        # Start the Telemetry supervisor
        HostingWeb.Telemetry,
        # Start the PubSub system
        {Phoenix.PubSub, name: :hosting},
        {Goth, name: Hosting.Goth},
        # Start the Endpoint (http/https)
        HostingWeb.Endpoint,
        {Cluster.Supervisor,
         [
           Application.fetch_env!(:libcluster, :topologies),
           [name: Affiliate.ClusterSupervisor]
         ]}
        # Start a worker by calling: Hosting.Worker.start_link(arg)
        # {Hosting.Worker, arg}
      ] ++ Application.get_env(:hosting, :children)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hosting.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    HostingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
