use Mix.Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

config :affable,
  k8s: Affable.MockK8s,
  http: Affable.MockHTTP,
  broadcaster: Affable.MockBroadcaster,
  google_service_account_json: System.fetch_env!("GOOGLE_SERVICE_ACCOUNT_JSON")

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :affable, Affable.Repo,
  username: "postgres",
  password: "postgres",
  database: "affable_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :affable, AffableWeb.Endpoint,
  http: [port: 4002],
  server: false

config :affable, Affable.Mailer, adapter: Bamboo.TestAdapter

# capture all logs
config :logger, level: :debug
# but only show warnings and up on the console
config :logger, :console, level: :warn
