defmodule AffableWeb.PageManagementTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Affable.Sites

  defp path(conn, %Sites.Site{pages: [page | _]} = site) do
    Routes.editor_path(conn, :edit, site.id, page.id)
    |> control_plane_path()
  end

  defp path(conn, action, id) do
    Routes.editor_path(conn, action, id)
    |> control_plane_path()
  end

  setup context do
    %{conn: conn, user: user} = register_and_log_in_user(context)
    [site] = user.sites
    %Sites.Site{pages: [page | _]} = site = site |> Sites.with_pages()

    %{
      conn: conn,
      user: user,
      site: site,
      page: page
    }
  end

  defp new_page(view, site) do
    view
    |> element("#new-page")
    |> render_click()

    List.last(Sites.page_ids(site))
  end

  test "can create a page, navigate to it and delete it", %{
    conn: conn,
    site: %Sites.Site{} = site
  } do
    {:ok, view, _html} =
      live(
        conn,
        path(conn, :edit, site.id)
      )

    id = new_page(view, site)

    view
    |> element(select_main_site_tab(), "Site")
    |> render_click()

    view
    |> element(select_page_tab(1), "Home")
    |> render_click()

    assert view
           |> has_element?("a", "Home")

    assert view
           |> element("iframe")
           |> render()
           |> String.contains?(~s(src="#{Sites.preview_url(site)}"))

    view
    |> element("a", "Delete page")
    |> render_click()

    refute view
           |> has_element?("a", "Home")

    view
    |> element(select_main_site_tab(), "Site")
    |> render_click()

    view
    |> element(select_page_tab(1), "Untitled page")
    |> render_click()

    assert view
           |> element("iframe")
           |> render()
           |> String.contains?(
             ~s(src="#{%{URI.parse(Sites.preview_url(site)) | path: "/untitled-page"}}")
           )

    view
    |> element("a", "Delete page")
    |> render_click()

    refute view |> has_element?("#page-choice-#{id}")
    refute view |> has_element?("#page-#{id}")

    expected_redirect_path = Routes.editor_path(conn, :edit, site.id)

    assert {:error, {:live_redirect, %{to: ^expected_redirect_path}}} =
             live(conn, Routes.editor_path(conn, :edit, site.id, id) |> control_plane_path())
  end

  test "invalid page attributes cause errors to be shown / cleared", %{
    conn: conn,
    site: site,
    page: page
  } do
    {:ok, view, _html} = live(conn, path(conn, site))

    view
    |> change_form(page, page: %{title: ""})
    |> render_change()

    refute view |> has_element?("#publish")
    assert view |> has_element?(".invalid-feedback")

    view
    |> change_form(page, page: %{title: "a lovely title"})
    |> render_change()

    refute view |> has_element?(".invalid-feedback")
  end

  test "valid page attributes are persisted", %{
    conn: conn,
    site: site,
    page: page
  } do
    {:ok, view, _html} = live(conn, path(conn, site))

    view
    |> change_form(page, page: %{title: "new page title"})
    |> render_submit()

    refute view |> has_element?(".invalid-feedback")
  end

  defp select_main_site_tab() do
    select_page_menu_item(1)
  end

  defp change_form(view, page, attrs) do
    form(view, select_form(page), attrs)
  end

  defp select_form(page) do
    "#page-#{page.id}"
  end
end
