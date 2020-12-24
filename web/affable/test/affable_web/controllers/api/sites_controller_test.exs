defmodule AffableWeb.Api.SitesControllerTest do
  use AffableWeb.ConnCase, async: true

  import Affable.SitesFixtures

  alias Affable.Sites

  setup do
    published = site_fixture()

    stub_broadcast()
    {:ok, unpublished} = Sites.update_site(published, %{"name" => "Unpublished name"})

    %{published: published, unpublished: unpublished}
  end

  test "can provide published state as JSON", %{conn: conn, published: site} do
    conn = get(conn, Routes.api_sites_path(conn, :show, site))
    assert json_response(conn, 200)["name"] == site.name
  end

  test "can provide preview state as JSON", %{
    conn: conn,
    unpublished: preview,
    published: site
  } do
    conn = get(conn, Routes.api_sites_path(conn, :preview, site))
    assert json_response(conn, 200)["name"] == preview.name
  end
end
