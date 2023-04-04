ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Hosting.Repo, :manual)
Hammox.defmock(Hosting.MockK8s, for: Hosting.K8s)
