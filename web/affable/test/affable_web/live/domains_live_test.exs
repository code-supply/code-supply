defmodule AffableWeb.DomainsLiveTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Affable.Accounts.User
  alias Affable.Sites.Site

  setup context do
    {:ok, register_and_log_in_user(context)}
  end

  test "validation errors are shown on the fly", %{
    conn: conn,
    user: %User{sites: [%Site{id: site_id}]}
  } do
    {:ok, view, _html} = live(conn, path(conn))

    assert view
           |> form("#new-domain", domain: %{name: "https://i.dunno.com", site_id: site_id})
           |> render_change() =~ "must be a valid domain"
  end

  test "validation errors are shown on submit", %{
    conn: conn,
    user: %User{sites: [%Site{id: site_id}]}
  } do
    {:ok, view, _html} = live(conn, path(conn))

    assert view
           |> form("#new-domain", domain: %{name: "https://i.dunno.com", site_id: site_id})
           |> render_submit() =~ "must be a valid domain"
  end

  test "can add a custom domain", %{
    conn: conn,
    user: %User{sites: [%Site{id: site_id}]}
  } do
    {:ok, view, _html} = live(conn, path(conn))

    assert view
           |> form("#new-domain", domain: %{name: "www.pizzas4u.example.com", site_id: site_id})
           |> render_submit() =~ "www.pizzas4u.example.com</a>"
  end

  defp path(conn) do
    Routes.domains_path(conn, :index)
  end
end
