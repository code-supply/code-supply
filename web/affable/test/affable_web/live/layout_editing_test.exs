defmodule AffableWeb.LayoutEditingTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Hammox

  alias Affable.Layouts
  alias Affable.Layouts.Layout
  alias Affable.Sites.Site

  setup :verify_on_exit!

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

  test "finalising a row resize persists the change and broadcasts", %{conn: conn, site: site} do
    {:ok, layout} =
      Layouts.create_layout(site, %{
        name: "basic",
        grid_template_rows: "40px 1fr 50px"
      })

    {:ok, view, _html} = live(conn, path(conn, site))

    view
    |> select_layout(layout)
    |> edit_layout()

    expect_broadcast(fn %Site{layout: layout} ->
      assert %Layout{grid_template_rows: "10px 1fr 50px"} = layout
    end)

    view
    |> element("[data-name=_adjustrow_0_0][phx-hook=RowResize")
    |> render_hook(:resizeRow, %{
      "row" => "0",
      "height" => 10
    })

    assert view
           |> element("#layout-editor")
           |> render() =~ ~r(grid-template-rows.+10px.+1fr.+50px)
  end

  test "finalising a column resize persists the change and broadcasts", %{conn: conn, site: site} do
    {:ok, layout} =
      Layouts.create_layout(site, %{
        name: "basic",
        grid_template_columns: "150px 1fr"
      })

    {:ok, view, _html} = live(conn, path(conn, site))

    view
    |> select_layout(layout)
    |> edit_layout()

    expect_broadcast(fn %Site{layout: layout} ->
      assert %Layout{grid_template_columns: "100px 1fr"} = layout
    end)

    view
    |> element("[data-name=_adjustcolumn_0_0][phx-hook=ColumnResize")
    |> render_hook(:resizeColumn, %{
      "column" => "0",
      "width" => 100
    })

    assert view
           |> element("#layout-editor")
           |> render() =~ ~r(grid-template-columns.+100px.+1fr)
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
