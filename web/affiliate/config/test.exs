import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :affiliate, AffiliateWeb.Endpoint,
  http: [port: 4002],
  server: false

config :affiliate,
  http: Affiliate.MockHTTP

# Print only warnings and errors during test
config :logger, level: :warn
