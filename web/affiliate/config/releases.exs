# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :affiliate, AffiliateWeb.Endpoint,
  check_origin: System.get_env("CHECK_ORIGINS") |> String.split(" "),
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  live_view: [signing_salt: System.fetch_env!("LIVE_VIEW_SIGNING_SALT")],
  secret_key_base: secret_key_base,
  server: true,
  url: [host: System.fetch_env!("URL_HOST")]

config :affiliate,
  children: [
    {Affiliate.SiteState,
     {
       System.get_env("PREVIEW_URL") || raise("Must set PREVIEW_URL"),
       System.get_env("PUBLISHED_URL") || raise("Must set PUBLISHED_URL")
     }}
  ]

config :affiliate, AffiliateWeb.Endpoint,
  force_ssl: [
    hsts: true,
    rewrite_on: [:x_forwarded_proto],
    exclude: [System.fetch_env!("TLS_REDIRECT_EXCLUDE_HOST")]
  ]
