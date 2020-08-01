ExUnit.configure(exclude: [external: true])
ExUnit.start()
Hammox.defmock(SiteOperator.MockAffiliateSite, for: SiteOperator.AffiliateSite)
