# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :affiliate, AffiliateWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "hidIpGHqKhPK7ZLkoPVi1gmtII6ziy7hhYCrvlwb5ahrYwAl3q9/M9eAT4l4nYsN",
  render_errors: [view: AffiliateWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: :affable,
  live_view: [signing_salt: "4i29Hv3I"]

config :affiliate,
  pubsub_topic_incoming: "devsite",
  pubsub_topic_requests: "devsiterequests"

config :libcluster,
  topologies: [
    default: [
      strategy: Cluster.Strategy.Epmd,
      config: [
        hosts: [:affable@pickle]
      ]
    ]
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
