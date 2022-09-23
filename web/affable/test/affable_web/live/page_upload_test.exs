defmodule AffableWeb.PageUploadTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Affable.Sites

  @content """
  <html><link rel="stYLeSheEt" href="/some-styles.css"><script src="foo.js"></script><h1>Hi there!</h1></html>
  """

  @css """
  p { font-weight: bold }
  """

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

  test "can upload content for a page - scripts and external styles are stripped", %{
    conn: conn,
    site: site
  } do
    [page] = site.pages
    [domain] = site.domains
    {:ok, view, _html} = live(conn, path(conn, :edit, site.id))

    view
    |> element(select_page_tab(1), "Home")
    |> render_click()

    view
    |> file_input("#page-#{page.id}", :content, [
      %{
        name: "index.html",
        content: @content,
        size: @content |> :erlang.byte_size(),
        type: "text/html"
      }
    ])
    |> render_upload("index.html")

    view
    |> form("#page-#{page.id}")
    |> render_submit

    assert build_conn()
           |> get("http://#{domain.name}/")
           |> html_response(200) == "<html><h1>Hi there!</h1></html>"
  end

  test "can upload a stylesheet for a site", %{conn: conn, site: site} do
    [domain] = site.domains
    {:ok, view, _html} = live(conn, path(conn, :edit, site.id))

    view
    |> element(select_page_tab(0), "Site")
    |> render_click()

    view
    |> file_input("#stylesheet-upload", :stylesheet, [
      %{
        name: "app.css",
        content: @css,
        size: :erlang.byte_size(@css),
        type: "text/css"
      }
    ])
    |> render_upload("app.css")

    conn =
      build_conn()
      |> get("http://#{domain.name}/stylesheets/app.css")

    assert Plug.Conn.get_resp_header(conn, "content-type") ==
             ["text/css; charset=utf-8"]

    assert response(conn, 404)

    view
    |> form("#site")
    |> render_submit()

    conn =
      build_conn()
      |> get("http://#{domain.name}/stylesheets/app.css")

    assert Plug.Conn.get_resp_header(conn, "content-type") == ["text/css; charset=utf-8"]

    assert response(conn, 200) == @css
  end

  defp path(conn, action, id) do
    Routes.editor_path(conn, action, id)
    |> control_plane_path()
  end
end
