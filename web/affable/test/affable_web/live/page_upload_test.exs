defmodule AffableWeb.PageUploadTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Affable.Sites

  @content """
  <html><h1>Hi there!</h1></html>
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

  test "can upload content for a page", %{conn: conn, site: site} do
    [page] = site.pages
    {:ok, view, _html} = live(conn, path(conn, :edit, site.id))

    view
    |> element(select_page_tab(1), "Home")
    |> render_click()

    view
    |> file_input("#page-#{page.id}", :content, [
      %{
        name: "homepage",
        content: @content,
        size: @content |> :erlang.byte_size(),
        type: "text/html"
      }
    ])
    |> render_upload("homepage")

    view
    |> form("#page-#{page.id}")
    |> render_submit
  end

  defp path(conn, action, id) do
    Routes.editor_path(conn, action, id)
    |> control_plane_path()
  end
end
