import Config

config :site_operator,
  affiliate_site: SiteOperator.MockAffiliateSite,
  k8s: SiteOperator.MockK8s

config :k8s,
  clusters: %{}

config :bonny,
  controllers: [],
  cluster_name: :test

config :logger,
  backends: [:console]
