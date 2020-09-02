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
  secret_key_base: secret_key_base,
  server: true

config :affiliate,
  children: [
    {Cluster.Supervisor,
     [
       [
         default: [
           strategy: Cluster.Strategy.Kubernetes,
           config: [
             kubernetes_node_basename: "affable",
             kubernetes_selector: "app=affable",
             kubernetes_namespace: "affable"
           ]
         ]
       ],
       [name: Affiliate.ClusterSupervisor]
     ]},
    {Affiliate.SiteState,
     {
       :affable,
       System.get_env("PUBSUB_TOPIC_INCOMING") || raise("Must set PUBSUB_TOPIC_INCOMING"),
       System.get_env("PUBSUB_TOPIC_REQUESTS") || raise("Must set PUBSUB_TOPIC_REQUESTS")
     }}
  ]
