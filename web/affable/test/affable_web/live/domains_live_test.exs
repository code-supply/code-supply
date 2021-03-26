defmodule AffableWeb.DomainsLiveTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Affable.Accounts.User
  alias Affable.Sites.Site
  alias Affable.Sites

  setup context do
    {:ok, register_and_log_in_user(context)}
  end

  test "can add and delete a custom domain", %{
    conn: conn,
    user: %User{sites: [%Site{id: site_id}]}
  } do
    {:ok, view, _html} = live(conn, path(conn))

    assert view
           |> form("#new-domain", domain: %{name: "www.pizzas4u.example.com", site_id: site_id})
           |> render_submit() =~ "www.pizzas4u.example.com</a>"

    %Site{domains: [_default_domain | [new_domain | _]]} = Sites.get_site!(site_id)

    refute view
           |> element("#delete-domain-#{new_domain.id}")
           |> render_click() =~ "www.pizzas4u.example.com</a>"
  end

  test "cannot delete an affable domain", %{
    conn: conn,
    user: %User{sites: [%Site{domains: [domain]}]}
  } do
    {:ok, view, _html} = live(conn, path(conn))

    refute view
           |> has_element?("#delete-domain-#{domain.id}")
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

  defp path(conn) do
    Routes.domains_path(conn, :index)
  end
end
