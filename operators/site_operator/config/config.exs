import Config

config :site_operator,
  site_maker: SiteOperator.K8sSiteMaker,
  k8s: SiteOperator.RealK8s,
  distribution_cookie: "atestcookie",
  affiliate_site_image: "nginx",
  pubsub_topic_requests: "sitestate",
  secret_key_generator: :generate

config :k8s,
  clusters: %{
    default: %{
      conn: "/tmp/microk8s-config",
      conn_opts: %{context: "microk8s"}
    }
  }

config :bonny,
  controllers: [
    SiteOperator.Controller.V1.AffiliateSite
  ],
  cluster_name: :default,
  namespace: :all,
  group: "site-operator.code.supply",
  labels: %{
    app: "site-operator"
  },
  resources: %{
    limits: %{cpu: "100m", memory: "200Mi"},
    requests: %{cpu: "100m", memory: "200Mi"}
  }

config :logger_json,
       :backend,
       formatter: LoggerJSON.Formatters.GoogleCloudLogger,
       metadata: :all

config :logger,
  backends: [LoggerJSON]

import_config "#{Mix.env()}.exs"
