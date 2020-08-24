ExUnit.configure(exclude: [external: true])
ExUnit.start()
Hammox.defmock(SiteOperator.MockSiteMaker, for: SiteOperator.SiteMaker)
Hammox.defmock(SiteOperator.MockK8s, for: SiteOperator.K8s)
