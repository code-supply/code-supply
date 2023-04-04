defmodule HostingWeb.AssetsLiveTest do
  use HostingWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Hosting.Accounts.User
  alias Hosting.Sites

  setup context do
    {:ok, register_and_log_in_user(context)}
  end

  test "shows message when there are no assets for a site", %{
    conn: conn,
    user: %User{} = user
  } do
    {:ok, _site} = Sites.create_bare_site(user, %{name: "site2"})

    {:ok, view, _html} = live(conn, url(~p"/assets"))

    assert view
           |> element(".resources")
           |> render() =~ "No assets have been uploaded"
  end

  test "can delete images", %{
    conn: conn,
    user: %User{sites: [site | _]}
  } do
    {:ok, view, _html} = live(conn, url(~p(/assets)))

    [first_asset | _] = Sites.reload_assets(site).assets

    view
    |> element("#delete-asset-#{first_asset.id}")
    |> render_click()

    refute view
           |> has_element?("#delete-asset-#{first_asset.id}")
  end
end
