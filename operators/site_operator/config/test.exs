import Config

config :site_operator,
  site_maker: SiteOperator.MockSiteMaker,
  k8s: SiteOperator.MockK8s,
  secret_key_generator: "testsecret"

config :k8s,
  clusters: %{}

config :bonny,
  controllers: [],
  cluster_name: :test

config :logger,
  backends: [:console]
