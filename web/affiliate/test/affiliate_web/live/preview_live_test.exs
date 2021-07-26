defmodule AffiliateWeb.PreviewLiveTest do
  use AffiliateWeb.ConnCase

  import Affiliate.Fixtures
  import Phoenix.LiveViewTest
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

  test "updates when new content arrives", %{conn: conn, site: site} do
    {:ok, view, disconnected_html} = live(conn, "/preview")
    assert disconnected_html =~ site["name"]
    assert render(view) =~ site["name"]

    assert view
           |> element("header img[alt=\"#{site["name"]}\"]")
           |> render() =~ site["site_logo_url"]

    fixture("site_update_message")
    |> put_in(["preview", "site_logo_url"], "http://example.com/something.jpeg")
    |> Affiliate.SiteState.store()

    assert view
           |> element("img[alt=\"#{site["name"]}\"]")
           |> render() =~ "example.com/something.jpeg"
  end
end
