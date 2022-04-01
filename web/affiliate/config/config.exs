# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :affiliate, AffiliateWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "hidIpGHqKhPK7ZLkoPVi1gmtII6ziy7hhYCrvlwb5ahrYwAl3q9/M9eAT4l4nYsN",
  render_errors: [view: AffiliateWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Affiliate.PubSub,
  live_view: [signing_salt: "4i29Hv3I"]

config :affiliate,
  children: [],
  http: Affiliate.RealHTTP

config :tailwind,
  version: "3.0.15",
  default: [
    args: ~w(
        --config=tailwind.config.js
        --input=css/app.css
        --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
