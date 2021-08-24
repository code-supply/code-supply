defmodule AffiliateWeb.PageLiveTest do
  use AffiliateWeb.ConnCase

  import Affiliate.Fixtures
  import Phoenix.LiveViewTest
  import Hammox
  import Access, only: [at: 1]

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

    {:ok, view, html} = live(conn, "/")

    refute html =~ site["name"]

    SiteState.store(incoming_payload)

    assert render(view) =~ site["name"]
  end

  test "serves preview", %{conn: conn} do
    incoming_payload = fixture("site_update_message")
    site = incoming_payload["preview"]

    {:ok, view, html} = live(conn, "/preview")

    refute html =~ site["name"]

    SiteState.store(incoming_payload)

    assert render(view) =~ site["name"]
  end

  test "shows attribute titles when available", %{conn: conn} do
    incoming_payload = fixture("site_update_message")

    assert get_in(incoming_payload, [
             "published",
             "pages",
             at(0),
             "items",
             at(0),
             "attributes",
             at(0),
             "name"
           ]) ==
             "Price"

    SiteState.store(incoming_payload)

    {:ok, view, _html} = live(conn, "/")

    assert view |> has_element?("th", "Price")
  end

  test "hides table when no items are available", %{conn: conn} do
    incoming_payload =
      fixture("site_update_message")
      |> put_in(["published", "pages", at(0), "items"], [])

    SiteState.store(incoming_payload)

    {:ok, view, _html} = live(conn, "/")

    refute view |> has_element?("table")
  end
end
