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

    {:ok, view, html} = live(conn, "/")

    refute html =~ site["name"]

    SiteState.store(incoming_payload)

    assert render(view) =~ site["name"]
  end

  test "shows attribute titles when available", %{conn: conn} do
    incoming_payload = fixture("site_update_message")

    assert get_in(incoming_payload, [
             "published",
             "items",
             Access.at(0),
             "attributes",
             Access.at(0),
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
      |> put_in(["published", "items"], [])

    SiteState.store(incoming_payload)

    {:ok, view, _html} = live(conn, "/")

    refute view |> has_element?("table")
  end
end
