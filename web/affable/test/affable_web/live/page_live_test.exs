# defmodule AffableWeb.PageLiveTest do
#   use AffableWeb.ConnCase, async: true
#   import Phoenix.LiveViewTest

#   alias Affable.Sites
#   alias Affable.Sites.Site

#   import Affable.SitesFixtures

#   test "renders a published site" do
#     site = site_fixture()

#     assert Sites.is_published?(site)

#     conn = get(build_conn(), :render)

#     {:ok, view, _html} = live(conn)

#     assert(false)
#   end

#   test "renders a preview of a site" do
#   end
# end
