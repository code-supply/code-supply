defmodule AffableWeb.PageLiveTest do
  use AffableWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Affable"
    assert render(page_live) =~ "Affable"
  end
end
