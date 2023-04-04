import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :hosting, Hosting.Repo,
  username: "hosting",
  database: "hosting_test#{System.get_env("MIX_TEST_PARTITION")}",
  socket_dir: "../../.postgres",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10,
  queue_target: 5000

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hosting, HostingWeb.Endpoint,
  http: [port: 4002],
  server: false

# In test we don't send emails.
config :hosting, Justatest.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

config :hosting,
  k8s: Hosting.MockK8s,
  storage: Hosting.FakeStorage

# capture all logs
config :logger, level: :debug
# but only show warnings and up on the console
config :logger, :console, level: :warn
