defmodule Affable.RealK8s do
  def deploy(domain_name) do
    {:ok, conn} = K8s.Conn.lookup(:default)
    operation = K8s.Client.create(Affable.K8sFactories.affiliate_site(domain_name))
    K8s.Client.run(operation, conn)
  end

  def undeploy(domain_name) do
    {:ok, conn} = K8s.Conn.lookup(:default)
    operation = K8s.Client.delete(Affable.K8sFactories.affiliate_site(domain_name))
    K8s.Client.run(operation, conn)
  end
end
