defmodule AffableWeb.K8sControllerTest do
  use AffableWeb.ConnCase, async: true

  import Affable.AccountsFixtures

  test "provides kubectl-consumable manifests", %{conn: conn} do
    conn = get(conn, Routes.k8s_path(conn, :index))
    response = json_response(conn, 200)
    assert response == ["hi"]
  end

  # test "every resource has the same label, so that --prune can do its thing"
end
