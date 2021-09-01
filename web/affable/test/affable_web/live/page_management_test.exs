defmodule AffableWeb.PageManagementTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Hammox

  alias Affable.Sites
  alias Affable.Sites.Site

  setup :verify_on_exit!

  defp path(conn, site) do
    Routes.editor_path(conn, :edit, site.id)
  end

  setup context do
    %{conn: conn, user: user} = register_and_log_in_user(context)
    [site] = user.sites

    %{
      conn: conn,
      user: user,
      site: site |> Sites.with_items() |> Sites.with_pages()
    }
  end

  test "can create a page and navigate to it", %{conn: conn, site: %Site{} = site} do
    {:ok, view, _html} = live(conn, path(conn, site))

    refute view
           |> has_element?("label", "Untitled page")

    view
    |> element("#new-page")
    |> render_click()

    assert view
           |> has_element?("label", "Untitled page")
  end
end
