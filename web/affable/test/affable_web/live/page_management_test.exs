defmodule AffableWeb.PageManagementTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Hammox

  alias Affable.Sites

  setup :verify_on_exit!

  defp path(conn, %Sites.Site{pages: [page | _]} = site) do
    Routes.editor_path(conn, :edit, site.id, page.id)
  end

  setup context do
    %{conn: conn, user: user} = register_and_log_in_user(context)
    [site] = user.sites
    %Sites.Site{pages: [page | _]} = site = site |> Sites.with_items() |> Sites.with_pages()

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

  def iframe_path(path) do
    ~r{src=".*affable\.app/preview#{path}"}
  end

  test "can create a page, navigate to it and delete it", %{
    conn: conn,
    site: %Sites.Site{} = site
  } do
    {:ok, view, _html} =
      live(
        conn,
        Routes.editor_path(conn, :edit, site.id)
      )

    stub_broadcast()

    id = new_page(view, site)

    assert view
           |> element("iframe")
           |> render() =~ iframe_path("/untitled-page")

    view
    |> element(select_main_site_tab(), "Site")
    |> render_click()

    assert view
           |> element("iframe")
           |> render() =~ iframe_path("")

    view
    |> element(select_page_tab(1), "Home")
    |> render_click()

    view
    |> element("a", "Delete page")
    |> render_click()

    assert view
           |> element("iframe")
           |> render() =~ iframe_path("/untitled-page")

    view
    |> element(select_main_site_tab(), "Site")
    |> render_click()

    assert view
           |> element("iframe")
           |> render() =~ iframe_path("/untitled-page")

    view
    |> element(select_page_tab(1), "Untitled page")
    |> render_click()

    assert view
           |> element("iframe")
           |> render() =~ iframe_path("/untitled-page")

    view
    |> element("a", "Delete page")
    |> render_click()

    refute view |> has_element?("#page-choice-#{id}")
    refute view |> has_element?("#page-#{id}")
  end

  test "changing the path updates the iframe, to avoid 404", %{conn: conn, site: site, page: page} do
    {:ok, view, _html} = live(conn, path(conn, site))

    stub_broadcast()

    view
    |> change_form(page, page: %{path: "/something-else"})
    |> render_change()

    assert view
           |> element("iframe")
           |> render() =~ ~r{src=".*affable\.app/preview/something-else"}
  end

  test "can add a section and set its attributes", %{conn: conn, site: site, page: page} do
    {:ok, view, _html} = live(conn, path(conn, site))

    expect_broadcast(fn
      %Sites.Site{pages: [%Sites.Page{sections: [%Sites.Section{name: "untitled-section"}]} | _]} ->
        nil
    end)

    view
    |> element("#new-section")
    |> render_click()

    expect_broadcast(fn
      %Sites.Site{pages: [%Sites.Page{sections: [%Sites.Section{name: "my-new-name"}]} | _]} ->
        nil
    end)

    view
    |> change_form(page, page: %{sections: ["0": %{name: "my-new-name"}]})
    |> render_change()

    assert view
           |> element("#page-#{page.id}_sections_0_name")
           |> render() =~ "my-new-name"
  end

  test "invalid page attributes cause errors to be shown / cleared", %{
    conn: conn,
    site: site,
    page: page
  } do
    {:ok, view, _html} = live(conn, path(conn, site))

    view
    |> change_form(page, page: %{cta_background_colour: "FF"})
    |> render_change()

    refute view |> has_element?("#publish")
    assert view |> has_element?(".invalid-feedback")

    stub_broadcast()

    view
    |> change_form(page, page: %{cta_background_colour: "FF0000"})
    |> render_change()

    refute view |> has_element?(".invalid-feedback")
  end

  defp select_main_site_tab() do
    select_page_menu_item(1)
  end

  defp select_page_tab(n) do
    select_page_menu_item(n + 1)
  end

  defp select_page_menu_item(n) do
    "#page-nav ul li:nth-child(#{n}) a"
  end

  defp change_form(view, page, attrs) do
    form(view, select_form(page), attrs)
  end

  defp select_form(page) do
    "#page-#{page.id}"
  end
end
