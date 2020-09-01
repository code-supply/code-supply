ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Affable.Repo, :manual)
Hammox.defmock(Affable.MockK8s, for: Affable.K8s)
Hammox.defmock(Affable.MockRawSiteRetriever, for: Affable.RawSiteRetriever)
