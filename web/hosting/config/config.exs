# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

host = "hosting.code.test"

config :hosting,
  ecto_repos: [Hosting.Repo],
  k8s: Hosting.RealK8s,
  storage: Hosting.GCSStorage,
  id_salt: "replacedinrelease",
  pubsub_topic_requests: "devsiterequests",
  bucket_name: "hosting-uploads-dev",
  access_key_id: "hosting-dev@code-supply.iam.gserviceaccount.com",
  children: [],
  frame_ancestor: host

# Configures the endpoint
config :hosting, HostingWeb.Endpoint,
  url: [host: host],
  secret_key_base: "xmJOBP9bmljDpmDuE5AUTOt1ryhJ4Tqteqfoz7BEZQozBIQUU2a1ggTI9+nuAQ8u",
  render_errors: [view: HostingWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: :hosting,
  live_view: [signing_salt: "SOJjYeds"],
  check_origin: {HostingWeb.Origin, :check_origin, []}

config :libcluster, topologies: []

config :tailwind,
  version: "3.1.4",
  default: [
    args: ~w(
        --config=tailwind.config.js
        --input=css/app.css
        --output=../priv/static/assets/app.css
      ),
    cd: Path.expand("../assets", __DIR__)
  ],
  path: System.get_env("MIX_TAILWIND_PATH")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :hosting, Hosting.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(src/app.ts --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ],
  path: System.get_env("MIX_ESBUILD_PATH")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
