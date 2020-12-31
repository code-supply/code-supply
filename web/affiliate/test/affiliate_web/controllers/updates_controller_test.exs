defmodule AffiliateWeb.UpdatesControllerTest do
  use AffiliateWeb.ConnCase

  alias Affiliate.SiteState
  alias Affiliate.MockHTTP

  import Affiliate.Fixtures
  import Hammox

  setup :set_mox_global

  setup do
    MockHTTP
    |> stub(:get, fn url ->
      case url do
        "http://some.published.url/" ->
          {:ok, %{"name" => "published site"}}

        "http://some.preview.url/" ->
          {:ok, %{"name" => "default state"}}
      end
    end)

    start_supervised!({
      SiteState,
      {"http://some.preview.url/", "http://some.published.url/"}
    })

    :ok
  end

  test "responds with 200 on success", %{conn: conn} do
    conn = put(conn, Routes.updates_path(conn, :update), fixture("site_update_message"))
    assert json_response(conn, 200)
  end

  test "updates site state", %{conn: conn} do
    update = fixture("site_update_message")

    put(conn, Routes.updates_path(conn, :update), update)

    assert SiteState.get().preview == update["preview"]
    assert SiteState.get().published == update["published"]
  end
end
