defmodule AffableWeb.PageControllerTest do
  use AffableWeb.ConnCase, async: true

  alias Affable.Sites

  import Affable.AccountsFixtures
  import Affable.SitesFixtures

  test "renders a published site" do
    site = site_fixture(user_fixture(), %{name: "my site"})
    [domain] = site.domains

    assert Sites.is_published?(site)

    conn = build_conn()
    conn = get(conn, "http://#{domain.name}" <> Routes.page_path(conn, :show, []))

    response = html_response(conn, 200)

    assert response =~ "<title>my site"
  end

  test "404s for things like favicons" do
    assert_error_sent 404, fn ->
      get(build_conn(), "http://localhost:4000/favicon.ico")
    end
  end

  # test "does not render unpublished stuff" do
  # end
end
