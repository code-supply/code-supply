defmodule AffiliateWeb.PageLiveTest do
  use AffiliateWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Phoenix.PubSub

  setup do
    start_supervised!({
      Affiliate.SiteState,
      {:affable, "testsite123", "testsiterequests"}
    })

    fixture_path = Path.dirname(__ENV__.file) <> "/../../../../fixtures/raw_site.ex"

    {incoming_site, _} = Code.eval_file(fixture_path)

    :ok = PubSub.broadcast(:affable, "testsite123", incoming_site)

    %{site: incoming_site}
  end

  test "disconnected and connected render", %{conn: conn, site: site} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ site["name"]
    assert render(page_live) =~ site["name"]
  end
end
