defmodule AffiliateWeb.PageLiveTest do
  use AffiliateWeb.ConnCase

  import Affiliate.Fixtures
  import Phoenix.LiveViewTest

  alias Phoenix.PubSub

  test "serves 200 when empty", %{conn: conn} do
    start_supervised!({
      Affiliate.SiteState,
      {:affable, "testsite123", "testsiterequests"}
    })

    incoming_payload =
      fixture("site_update_message")
      |> Map.replace(:preview, %{})
      |> Map.replace(:published, %{})

    :ok = PubSub.broadcast(:affable, "testsite123", incoming_payload)

    conn = get(conn, "/")

    assert html_response(conn, 200)
  end

  describe "with content" do
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
      {:ok, page_live, disconnected_html} = live(conn, "/")
      assert disconnected_html =~ site["name"]
      assert render(page_live) =~ site["name"]
    end

    test "ignores append messages", %{conn: conn} do
      {:ok, page, _html} = live(conn, "/")

      append_payload = fixture("item_append_message")

      :ok = PubSub.broadcast(:affable, "testsite123", append_payload)

      refute render(page) =~ append_payload.append.item["name"]
    end
  end
end
