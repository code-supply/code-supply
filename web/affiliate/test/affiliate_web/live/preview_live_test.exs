defmodule AffiliateWeb.PreviewLiveTest do
  use AffiliateWeb.ConnCase

  import Affiliate.Fixtures
  import Phoenix.LiveViewTest
  import Access, only: [filter: 1]
  import Hammox

  alias Affiliate.MockHTTP

  setup :set_mox_global

  setup do
    incoming_payload = fixture("site_update_message")

    MockHTTP
    |> stub(:get, fn url ->
      case url do
        "previewurl" ->
          {:ok, incoming_payload["preview"]}

        "publishedurl" ->
          {:ok, incoming_payload["published"]}
      end
    end)

    start_supervised!({
      Affiliate.SiteState,
      {"previewurl", "publishedurl"}
    })

    %{site: incoming_payload["preview"]}
  end

  test "updates when new content arrives", %{conn: conn} do
    {:ok, view, disconnected_html} = live(conn, "/preview")
    assert disconnected_html =~ "<main"
    assert render(view) =~ "<main"
    refute render(view) =~ "example.com"

    fixture("site_update_message")
    |> put_in(
      ["preview", "layout", "sections", filter(fn s -> s["element"] == "header" end), "content"],
      "![logo](http://example.com/something.jpeg)"
    )
    |> Affiliate.SiteState.store()

    assert view
           |> element("img[alt=\"logo\"]")
           |> render() =~ "example.com/something.jpeg"
  end
end
