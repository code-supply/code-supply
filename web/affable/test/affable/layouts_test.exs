defmodule Affable.LayoutsTest do
  use Affable.DataCase, async: true

  import Affable.SitesFixtures
  import Affable.AccountsFixtures
  import Hammox

  alias Affable.Sites
  alias Affable.Sites.{Section, Site}
  alias Affable.Layouts
  alias Affable.Layouts.Layout

  setup :verify_on_exit!

  test "can retrieve layout" do
    user = user_fixture()
    [site] = user.sites
    {:ok, layout} = Layouts.create_layout(site, %{name: "basic"})

    retrieved = Layouts.get!(user, layout.id)
    assert layout == retrieved
  end

  test "layout editor controls can be added to sections, template areas, rows and columns" do
    sections = [
      header = %Section{name: "header", element: "header", background_colour: "000000"},
      nav = %Section{name: "nav", element: "nav", background_colour: "00FF00"},
      main = %Section{name: "main", element: "main", background_colour: "0000FF"},
      footer = %Section{name: "footer", element: "footer", background_colour: "FFFF00"}
    ]

    grid_template_areas = ~s("header header"
"nav main"
"footer footer")

    layout = %Layout{
      name: "my layout",
      sections: sections,
      grid_template_areas: grid_template_areas,
      grid_template_rows: ~s(50px 1fr 50px),
      grid_template_columns: ~s(150px 1fr)
    }

    adjuster0 = %Section{id: "rowadjust0", name: "_rowadjust0", element: "div"}
    adjuster1 = %Section{id: "rowadjust1", name: "_rowadjust1", element: "div"}

    assert [
             {0, header},
             {0, adjuster0},
             {1, nav},
             {1, main},
             {1, adjuster1},
             {2, footer}
           ] ==
             Layouts.editor_sections(layout)

    assert ~s("header header"
"_rowadjust0 _rowadjust0"
"nav main"
"_rowadjust1 _rowadjust1"
"footer footer") == Layouts.editor_grid_template_areas(layout)

    bar = Layouts.resize_bar_width()

    assert ~s{calc(50px - #{bar}) #{bar} calc(1fr - #{bar}) #{bar} 50px} ==
             Layouts.editor_grid_template_rows("50px 1fr 50px")
  end

  test "layout editor controls aren't added to single row layouts" do
    layout = %Layout{
      name: "my layout",
      sections: [%Section{name: "one"}],
      grid_template_areas: "one",
      grid_template_rows: "1fr",
      grid_template_columns: ~s(1fr)
    }

    assert ~s("one") == Layouts.editor_grid_template_areas(layout)
    assert ~s{1fr} == Layouts.editor_grid_template_rows("1fr")
  end

  test "layout editor controls aren't added to empty or nil layouts" do
    empty_layout = %Layout{
      name: "my layout",
      sections: [],
      grid_template_areas: "",
      grid_template_rows: "",
      grid_template_columns: ~s(150px 1fr)
    }

    assert ~s("") == Layouts.editor_grid_template_areas(empty_layout)

    assert ~s{} ==
             Layouts.editor_grid_template_rows("")

    nil_layout = %Layout{
      name: "my layout",
      sections: [],
      grid_template_areas: nil,
      grid_template_rows: nil,
      grid_template_columns: ~s(150px 1fr)
    }

    assert ~s("") == Layouts.editor_grid_template_areas(nil_layout)

    assert ~s{} ==
             Layouts.editor_grid_template_rows(nil)
  end

  test "new layout has header, nav, main and footer sections, in a grid" do
    site = site_fixture()
    {:ok, layout} = Layouts.create_layout(site, %{name: "basic"})

    assert [layout.id] == for(l <- Layouts.all(), do: l.id)

    assert ~w(header nav main footer) == for(s <- layout.sections, do: s.element)
    assert ~s("header header"
"nav main"
"footer footer") == layout.grid_template_areas
    assert ~s(50px 1fr 50px) == layout.grid_template_rows
    assert ~s(150px 1fr) == layout.grid_template_columns
  end

  test "resizing a row causes layout to shift" do
    assert "101px 2px 3px" == Layouts.resize_grid_template_row("1px 2px 3px", "0", 100)
  end

  test "can save and broadcast a layout change" do
    user = user_fixture()
    [site] = user.sites

    {:ok, layout} =
      Layouts.create_layout(site, %{
        name: "basic",
        grid_template_rows: "50px 1fr 50px"
      })

    stub_broadcast()
    {:ok, _site} = Sites.update_site(site, %{layout_id: layout.id})

    expect_broadcast(fn %Site{layout: layout} ->
      assert %Layout{grid_template_rows: "150px 1fr 50px"} = layout
    end)

    {:ok, layout} = Layouts.update(user, layout, %{grid_template_rows: "150px 1fr 50px"})

    [reloaded_layout] = Layouts.all()

    assert layout.grid_template_rows == "150px 1fr 50px"
    assert reloaded_layout == layout
  end

  test "resizing row with incorrect user is not allowed" do
    user = user_fixture()
    [site] = user.sites
    {:ok, layout} = Layouts.create_layout(site, %{name: "basic"})

    {:error, :unauthorized} = Layouts.update(wrong_user(), layout, %{grid_template_rows: "foo"})
  end
end
