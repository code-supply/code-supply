defmodule AffableWeb.PageControllerTest do
  use AffableWeb.ConnCase, async: true

  alias Affable.Sites

  import Affable.AccountsFixtures
  import Affable.SitesFixtures

  test "renders a site" do
    user = user_fixture()
    site = site_fixture(user, %{name: "my site"})

    [domain] = site.domains

    [page] = site.pages

    {:ok, _page} =
      Sites.update_page(page, %{"raw" => "<html><title>my site</title></html>"}, user)

    conn = build_conn()
    conn = get(conn, "http://#{domain.name}" <> Routes.page_path(conn, :show, []))

    response = html_response(conn, 200)

    assert response =~ "<title>my site"
  end

  test "404s for arbitrary missing stuff at root" do
    assert_error_sent(404, fn ->
      get(build_conn(), "http://localhost:4000/not-there.png")
    end)
  end

  test "only permits iframing inside control site" do
    user = user_fixture()
    site = site_fixture(user, %{name: "my site"})

    [domain] = site.domains

    [page] = site.pages

    {:ok, _page} =
      Sites.update_page(page, %{"raw" => "<html><title>my site</title></html>"}, user)

    conn = build_conn()
    conn = get(conn, "http://#{domain.name}" <> Routes.page_path(conn, :show, []))

    headers = Enum.into(conn.resp_headers, %{})

    assert nil == headers["x-frame-options"]

    assert "frame-ancestors #{Application.get_env(:affable, :frame_ancestor)}" ==
             headers["content-security-policy"]
  end
end
