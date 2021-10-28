import Config

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  config :affable, Affable.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  config :affable,
    id_salt:
      System.get_env("ID_SALT") ||
        raise("""
        environment variable ID_SALT is missing.
        """),
    live_view: [signing_salt: System.fetch_env!("LIVE_VIEW_SIGNING_SALT")],
    bucket_name: System.fetch_env!("BUCKET_NAME"),
    access_key_id: System.fetch_env!("ACCESS_KEY_ID")

  config :affable, AffableWeb.Endpoint,
    url: [scheme: "https", port: 443],
    http: [
      port: String.to_integer(System.get_env("PORT") || "4000"),
      transport_options: [socket_opts: [:inet6]],
      compress: true
    ],
    secret_key_base: secret_key_base,
    server: true

  config :affable, Affable.Mailer,
    adapter: Bamboo.SendGridAdapter,
    api_key:
      System.get_env("SENDGRID_API_KEY") ||
        raise("""
        environment variable SENDGRID_API_KEY is missing.
        """)

  config :goth, source: {:metadata, []}

  config :bamboo,
    sendgrid_base_uri: "https://api.sendgrid.com/v3/"
end
