defmodule AffiliateWeb.PreviewLiveTest do
  use AffiliateWeb.ConnCase

  import Affiliate.Fixtures
  import Phoenix.LiveViewTest

  alias Phoenix.PubSub

  setup do
    start_supervised!({
      Affiliate.SiteState,
      {:affable, "testsite123", "testsiterequests"}
    })

    incoming_payload = fixture("site_update_message")

    :ok = PubSub.broadcast(:affable, "testsite123", incoming_payload)

    %{site: incoming_payload.preview}
  end

  test "disconnected and connected render", %{conn: conn, site: site} do
    {:ok, page_live, disconnected_html} = live(conn, "/preview")
    assert disconnected_html =~ site["name"]
    assert render(page_live) =~ site["name"]
  end

  test "appends items", %{conn: conn} do
    {:ok, page, _html} = live(conn, "/preview")

    append_payload = fixture("item_append_message")

    :ok = PubSub.broadcast(:affable, "testsite123", append_payload)

    assert render(page) =~ append_payload.append.item["name"]
  end
end
