defmodule AffableWeb.SitesLiveTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import ExUnit.CaptureLog

  alias Affable.Accounts.User
  alias Affable.Sites.Site

  import Ecto.Query, only: [from: 2]

  setup context do
    {:ok, register_and_log_in_user(context)}
  end

  test "shows spinner until site is available", %{conn: conn, user: %User{sites: [site]}} do
    {:ok, view, _html} = live(conn, path(conn))

    assert view |> has_element?(".pending")

    assert capture_log(fn ->
             all_sites_become_available()
             view |> has_element?(".available")
           end) =~ "Received site #{site.internal_name}"

    refute view |> has_element?(".pending")
    assert view |> has_element?(".available")
  end

  test "can make a new site", %{conn: conn} do
    {:ok, view, _html} = live(conn, path(conn))

    assert view
           |> form("#new-site", site: %{name: "The best pizzas"})
           |> render_submit() =~ "The best pizzas</h2>"

    all_sites_become_available()

    refute view |> has_element?(".pending")
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

    assert 0 == from(Site, select: count()) |> Affable.Repo.one()
  end

  defp all_sites_become_available() do
    made_available_at = DateTime.utc_now()

    for site <- all_sites() do
      Phoenix.PubSub.broadcast(:affable, site.internal_name, %{
        site
        | made_available_at: made_available_at
      })
    end
  end

  defp all_sites() do
    from(Site, preload: [:domains])
    |> Affable.Repo.all()
  end

  defp path(conn) do
    AffableWeb.Router.Helpers.sites_path(conn, :index)
    |> control_plane_path()
  end
end
