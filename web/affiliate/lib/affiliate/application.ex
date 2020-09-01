defmodule Affiliate.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      AffiliateWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: :affable},
      # Start the Endpoint (http/https)
      AffiliateWeb.Endpoint,
      {Cluster.Supervisor,
       [
         Application.get_env(:libcluster, :topologies),
         [name: Affiliate.ClusterSupervisor]
       ]},
      {Affiliate.SiteState,
       {
         :affable,
         Application.get_env(:affiliate, :pubsub_topic_incoming),
         Application.get_env(:affiliate, :pubsub_topic_requests)
       }}

      # Start a worker by calling: Affiliate.Worker.start_link(arg)
      # {Affiliate.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Affiliate.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AffiliateWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
