defmodule AffableWeb.K8sController do
  use AffableWeb, :controller

  def index(conn, _params) do
    k8s = ["hi"]

    render(conn, "index.json", k8s: k8s)
  end
end
