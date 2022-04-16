defmodule AffableWeb.PageLiveTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Affable.Sites
  alias Affable.Sites.Site

  import Affable.AccountsFixtures
  import Affable.SitesFixtures

  test "renders a published site" do
    site = site_fixture(user_fixture(), %{name: "my site"})
    [domain] = site.domains

    assert Sites.is_published?(site)

    conn = build_conn()

    IO.inspect(domain.name)

    conn = get(conn, "http://#{domain.name}/" <> Routes.page_path(conn, :index, ["/"]))

    {:ok, view, _html} = live(conn)

    assert render(view) =~ "my site"
  end

  test "renders a preview of a site" do
  end
end
