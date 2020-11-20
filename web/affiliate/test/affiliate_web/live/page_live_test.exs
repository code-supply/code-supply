defmodule AffiliateWeb.PageLiveTest do
  use AffiliateWeb.ConnCase

  import Affiliate.Fixtures
  import Phoenix.LiveViewTest

  alias Phoenix.PubSub

  setup do
    start_supervised!({
      Affiliate.SiteState,
      {:affable, "testsite123", "testsiterequests"}
    })

    incoming_payload = site_update_message()

    :ok = PubSub.broadcast(:affable, "testsite123", incoming_payload)

    %{site: incoming_payload.preview}
  end

  test "disconnected and connected render", %{conn: conn, site: site} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ site["name"]
    assert render(page_live) =~ site["name"]
  end
end
