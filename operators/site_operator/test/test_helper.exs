ExUnit.configure(exclude: [external: true])
ExUnit.start()
Hammox.defmock(SiteOperator.MockAffiliateSite, for: SiteOperator.AffiliateSite)
Hammox.defmock(SiteOperator.MockK8s, for: SiteOperator.K8s)
