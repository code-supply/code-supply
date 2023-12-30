defmodule HostingWeb.SitesLiveTest do
  use HostingWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Hosting.Accounts.User
  alias Hosting.Sites.Site
  alias HostingWeb.Router

  import Ecto.Query, only: [from: 2]

  setup context do
    {:ok, register_and_log_in_user(context)}
  end

  test "can make a new site", %{conn: conn} do
    {:ok, view, _html} = live(conn, path(conn))

    assert view
           |> form("#new-site", site: %{name: "The best pizzas"})
           |> render_submit() =~ "The best pizzas</h2>"
  end

  test "entering an empty name shows error", %{conn: conn} do
    {:ok, view, _html} = live(conn, path(conn))

    assert view
           |> form("#new-site", site: %{name: " "})
           |> render_submit() =~ "can&#39;t be blank"
  end

  test "can delete sites", %{conn: conn, user: %User{sites: [site]}} do
    {:ok, view, html} = live(conn, path(conn))

    assert html =~ site.name

    refute view
           |> element("#delete-site-#{site.id}")
           |> render_click() =~ site.name

    assert 0 == from(Site, select: count()) |> Hosting.Repo.one()
  end

  defp path(conn) do
    Router.Helpers.sites_path(conn, :index)
    |> control_plane_path()
  end
end
