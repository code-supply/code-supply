defmodule AffableWeb.PageLiveTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Affable.Sites

  import Affable.AccountsFixtures
  import Affable.SitesFixtures

  test "renders a published site" do
    site = site_fixture(user_fixture(), %{name: "my site"})
    [domain] = site.domains

    assert Sites.is_published?(site)

    conn = build_conn()
    conn = get(conn, "http://#{domain.name}" <> Routes.page_path(conn, :index, []))

    {:ok, _view, html} = live(conn)

    assert html =~ "<title>my site"
  end

  # test "does not render unpublished stuff" do
  #   site = site_fixture(user_fixture(), %{name: "my site"})
  #   [domain] = site.domains
  #   [page] = site.pages

  #   Sites.update_page(page,

  #   conn = build_conn()
  #   conn = get(conn, "http://#{domain.name}" <> Routes.page_path(conn, :index, []))

  #   {:ok, _view, html} = live(conn)

  #   assert html =~ "<title>my site"
  # end
end
