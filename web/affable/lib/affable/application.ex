defmodule Affable.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Affable.Repo,
      # Start the Telemetry supervisor
      AffableWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: :affable},
      # Start the Endpoint (http/https)
      AffableWeb.Endpoint,
      # Start a worker by calling: Affable.Worker.start_link(arg)
      # {Affable.Worker, arg}
      {Affable.SiteUpdater,
       {
         Affable.Sites,
         :affable,
         Application.get_env(:affable, :pubsub_topic_requests)
       }}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Affable.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AffableWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
