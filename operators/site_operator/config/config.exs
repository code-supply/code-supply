import Config

config :site_operator,
  affiliate_site: SiteOperator.K8sAffiliateSite,
  k8s: SiteOperator.RealK8s

config :k8s,
  clusters: %{
    default: %{
      conn: "~/.kube/config",
      conn_opts: %{context: "site-operator-test"}
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
