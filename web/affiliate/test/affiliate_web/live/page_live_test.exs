defmodule AffiliateWeb.PageLiveTest do
  use AffiliateWeb.ConnCase

  import Affiliate.Fixtures
  import Phoenix.LiveViewTest
  import Hammox

  alias Affiliate.MockHTTP
  alias Affiliate.SiteState

  setup :set_mox_global

  setup do
    MockHTTP
    |> stub(:get, fn _anyURL -> {:ok, %{}} end)

    start_supervised!({SiteState, {"previewurl", "publishedurl"}})

    %{}
  end

  test "serves 200 when empty", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200)
  end

  test "serves content", %{conn: conn} do
    incoming_payload = fixture("site_update_message")
    site = incoming_payload["published"]

    SiteState.store(incoming_payload)

    {:ok, page_live, html} = live(conn, "/")

    assert html =~ site["name"]
    assert render(page_live) =~ site["name"]
  end
end
