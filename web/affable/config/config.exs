# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :affable,
  ecto_repos: [Affable.Repo],
  k8s: Affable.RealK8s,
  id_salt: "replacedinrelease",
  broadcaster: Affable.SiteUpdater,
  http: Affable.RealHTTP,
  pubsub_topic_requests: "devsiterequests",
  bucket_name: "affable-uploads-dev",
  access_key_id: "affable-dev@code-supply.iam.gserviceaccount.com",
  children: []

# Configures the endpoint
config :affable, AffableWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "xmJOBP9bmljDpmDuE5AUTOt1ryhJ4Tqteqfoz7BEZQozBIQUU2a1ggTI9+nuAQ8u",
  render_errors: [view: AffableWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: :affable,
  live_view: [signing_salt: "SOJjYeds"]

config :libcluster, topologies: []

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :affable, Affable.Mailer, adapter: Bamboo.LocalAdapter

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(src/app.ts --bundle --target=es2016 --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ],
  css: [
    args: ~w(build/app.css --outdir=../priv/static/assets),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
