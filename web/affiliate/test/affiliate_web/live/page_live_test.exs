defmodule AffiliateWeb.PageLiveTest do
  use AffiliateWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Affiliate"
    assert render(page_live) =~ "Affiliate"
  end
end
