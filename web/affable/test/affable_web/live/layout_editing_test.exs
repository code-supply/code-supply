defmodule AffableWeb.LayoutEditingTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Affable.Layouts

  setup context do
    %{conn: conn, user: user} = register_and_log_in_user(context)
    [site] = user.sites

    %{
      conn: conn,
      site: site
    }
  end

  test "can choose and edit layout", %{
    conn: conn,
    site: site
  } do
    {:ok, layout} = Layouts.create_layout(site, %{name: "basic"})
    {:ok, view, _html} = live(conn, path(conn, site))

    refute view
           |> select_layout(layout)
           |> edit_layout()
           |> has_element?("iframe")

    assert view
           |> deselect_layout()
           |> has_element?("iframe")
  end

  test "resizing a section causes other sections to resize", %{conn: conn, site: site} do
    {:ok, layout} = Layouts.create_layout(site, %{name: "basic"})
    {:ok, view, _html} = live(conn, path(conn, site))

    view
    |> select_layout(layout)
    |> edit_layout()

    refute view
           |> element("main[data-name=main]")
           |> render() =~ "height"

    assert view
           |> render_hook(:resize, %{
             "name" => "main",
             "blockSize" => "100",
             "inlineSize" => "100"
           }) =~ "foo"

    assert view
           |> element("#layout-editor")
           |> render() =~ ~r(grid-template-rows.*50px 100px 50px)
  end

  defp path(conn, site) do
    Routes.editor_path(conn, :edit, site.id)
  end

  defp select_layout(view, layout) do
    assert view
           |> has_element?("#site_layout_id option[value=#{layout.id}]")

    stub_broadcast()

    view |> render_change(:save, %{"site" => %{"layout_id" => "#{layout.id}"}})

    assert view
           |> has_element?("#site_layout_id option[value=#{layout.id}][selected]")

    view
  end

  defp deselect_layout(view) do
    view
    |> render_change(:save, %{
      "site" => %{
        "layout_id" => nil
      }
    })

    view
  end

  defp edit_layout(view) do
    view
    |> element("#site-layout-edit")
    |> render_click()

    view
  end
end
