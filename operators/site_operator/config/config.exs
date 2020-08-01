import Config

config :site_operator,
  affiliate_site: SiteOperator.K8sAffiliateSite

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
  group: "site-operator.code.supply"

import_config "#{Mix.env()}.exs"
