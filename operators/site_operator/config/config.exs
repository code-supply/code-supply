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
  cluster_name: "default",
  namespace: :all,
  group: "site-operator.code.supply",

  # Bonny will default to using your current-context, optionally set cluster: and user: here.
  # kubeconf_opts: [cluster: "my-cluster", user: "my-user"]
  kubeconf_opts: [
    cluster: "gke_code-supply_europe-west1-b_pink",
    user: "gke_code-supply_europe-west1-b_pink"
  ]
