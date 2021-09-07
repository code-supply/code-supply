defmodule AffableWeb.PageManagementTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Hammox

  alias Affable.Sites
  alias Affable.Sites.{Page, Site}

  setup :verify_on_exit!

  defp path(conn, %Site{pages: [page | _]} = site) do
    Routes.editor_path(conn, :edit, site.id, page.id)
  end

  setup context do
    %{conn: conn, user: user} = register_and_log_in_user(context)
    [site] = user.sites
    %Site{pages: [page | _]} = site = site |> Sites.with_items() |> Sites.with_pages()

    %{
      conn: conn,
      user: user,
      site: site,
      page: page
    }
  end

  test "can create a page, navigate to it and delete it", %{conn: conn, site: %Site{} = site} do
    {:ok, view, _html} =
      live(
        conn,
        Routes.editor_path(conn, :edit, site.id)
      )

    stub_broadcast()

    view
    |> element("#new-page")
    |> render_click()

    id = List.last(Sites.page_ids(site))

    assert view
           |> has_element?("#page-#{id}")

    assert view
           |> element("iframe")
           |> render() =~ ~r{src=".*affable\.app/preview/untitled-page"}

    view
    |> element("#site-choice a")
    |> render_click()

    assert view
           |> element("iframe")
           |> render() =~ ~r{src=".*affable\.app/preview"}

    view
    |> element("#page-choice-#{id} a")
    |> render_click()

    assert view
           |> has_element?("#page-#{id}")

    assert view
           |> element("iframe")
           |> render() =~ ~r{src=".*affable\.app/preview/untitled-page"}

    view
    |> element("#delete-page-#{id}")
    |> render_click()

    refute view
           |> has_element?("#page-choice-#{id}")

    refute view
           |> has_element?("#page-#{id}")
  end

  test "can set header properties", %{conn: conn, site: site, page: page} do
    {:ok, view, _html} = live(conn, path(conn, site))

    expect_broadcast(fn %Site{pages: [%Page{header_text: header_text} | _]} ->
      assert "new header text" == header_text
    end)

    view
    |> element("#page-#{page.id}")
    |> render_change(%{page: %{header_text: "new header text"}})

    assert view |> has_element?("#publish")

    expect_broadcast(fn %Site{pages: [%Page{header_text: header_text} | _]} ->
      assert "new header text" == header_text
    end)

    view
    |> element("#new-item-top")
    |> render_click()

    conn = get(conn, path(conn, site))
    assert conn.resp_body =~ "new header text"
  end

  test "invalid page attributes cause errors to be shown / cleared", %{
    conn: conn,
    site: site,
    page: page
  } do
    {:ok, view, _html} = live(conn, path(conn, site))

    view
    |> element("#page-#{page.id}")
    |> render_change(%{page: %{cta_background_colour: "FF"}})

    refute view |> has_element?("#publish")
    assert view |> has_element?(".invalid-feedback")

    stub_broadcast()

    view
    |> element("#page-#{page.id}")
    |> render_change(%{page: %{cta_background_colour: "FF0000"}})

    refute view |> has_element?(".invalid-feedback")
  end
end
