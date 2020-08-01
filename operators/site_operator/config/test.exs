import Config

config :site_operator,
  affiliate_site: SiteOperator.MockAffiliateSite

config :k8s,
  clusters: %{}

config :bonny,
  controllers: [],
  cluster_name: :test
