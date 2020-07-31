import Config

config :k8s,
  clusters: %{
    default: %{
      conn: "~/.kube/config"
    }
  }

config :bonny,
  # Add each CRD Controller module for this operator to load here
  controllers: [
    SiteOperator.Controller.V1.Site
  ],
  cluster_name: :default,
  namespace: :all,
  group: "site-operator.code.supply"
