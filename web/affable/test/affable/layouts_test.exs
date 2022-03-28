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

  describe "layout editor controls" do
    setup do
      sections = [
        %Section{name: "header", element: "header", background_colour: "000000"},
        %Section{name: "nav", element: "nav", background_colour: "00FF00"},
        %Section{name: "main", element: "main", background_colour: "0000FF"},
        %Section{name: "social", element: "section", background_colour: "0000FF"},
        %Section{name: "footer", element: "footer", background_colour: "FFFF00"}
      ]

      grid_template_areas = ~s("header header"
"nav main"
"nav social"
"footer footer")

      %{
        bar: Layouts.resize_bar_width(),
        grid:
          Layouts.editor_grid(%Layout{
            name: "my layout",
            sections: sections,
            grid_template_areas: grid_template_areas,
            grid_template_rows: ~s(50px 1fr 1fr 50px),
            grid_template_columns: ~s(150px 1fr)
          }),
        sections: sections
      }
    end

    test "can be added to sections", %{grid: grid, sections: sections} do
      assert [
               "_adjustcolumn_0",
               "_adjustcolumn_1",
               "_adjustrow_0",
               "header",
               "nav",
               "main",
               "_adjustrow_1",
               "social",
               "_adjustrow_2",
               "footer",
               "_adjustrow_3"
             ] = Layouts.sections(grid, sections) |> Enum.map(& &1.name)
    end

    test "can be added to template areas", %{grid: grid} do
      assert ~s("_adjustcolumn_0 _adjustcolumn_1 _adjustrow_0"
"header header _adjustrow_0"
"nav main _adjustrow_1"
"nav social _adjustrow_2"
"footer footer _adjustrow_3") == Layouts.format_areas(grid)
    end

    test "can be added to template rows", %{grid: grid, bar: bar} do
      assert ~s{#{bar} 50px 1fr 1fr 50px} ==
               Layouts.format_measurements(grid.rows)
    end

    test "can be added to template columns", %{grid: grid, bar: bar} do
      assert ~s{150px 1fr #{bar}} ==
               Layouts.format_measurements(grid.columns)
    end
  end

  test "layout editor controls aren't added to single row layouts" do
    layout = %Layout{
      name: "my layout",
      sections: [%Section{name: "one"}],
      grid_template_areas: "one",
      grid_template_rows: "1fr",
      grid_template_columns: ~s(1fr)
    }

    grid = Layouts.editor_grid(layout)

    assert ~s("one") == Layouts.format_areas(grid)
    assert ~s{1fr} == Layouts.format_measurements(~w(1fr))
  end

  test "layout editor controls aren't added to empty or nil layouts" do
    empty_layout = %Layout{
      name: "my layout",
      sections: [],
      grid_template_areas: "",
      grid_template_rows: "",
      grid_template_columns: ~s(150px 1fr)
    }

    empty_grid = Layouts.editor_grid(empty_layout)

    assert ~s("") == Layouts.format_areas(empty_grid)
    assert ~s{} == Layouts.format_measurements(empty_grid.rows)

    nil_layout = %Layout{
      name: "my layout",
      sections: [],
      grid_template_areas: nil,
      grid_template_rows: nil,
      grid_template_columns: ~s(150px 1fr)
    }

    nil_grid = Layouts.editor_grid(nil_layout)

    assert ~s("") == Layouts.format_areas(nil_grid)
    assert ~s{} == Layouts.format_measurements(nil_grid.rows)
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
    assert "100px 2px 3px" == Layouts.change_grid_template_size("1px 2px 3px", "0", 100)
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

  test "can save and broadcast a section change" do
    user = user_fixture()
    [site] = user.sites

    {:ok, layout} =
      Layouts.create_layout(site, %{
        name: "basic",
        grid_template_rows: "50px 1fr 50px"
      })

    stub_broadcast()
    {:ok, _site} = Sites.update_site(site, %{layout_id: layout.id})

    [section | _] = layout.sections
    refute "main" == section.element

    expect_broadcast(fn %Site{layout: layout} ->
      assert Enum.any?(layout.sections, &(&1.id == section.id and &1.element == "main"))
    end)

    {:ok, section} = Layouts.update_section(user, %{"element" => "main", "id" => "#{section.id}"})

    assert "main" == section.element
  end

  test "updating a section with incorrect user is not allowed" do
    user = user_fixture()
    [site] = user.sites

    {:ok, layout} =
      Layouts.create_layout(site, %{
        name: "basic",
        grid_template_rows: "50px 1fr 50px"
      })

    [section | _] = layout.sections

    old_element = section.element

    assert {:error, :unauthorized} =
             Layouts.update_section(wrong_user(), %{"element" => "main", "id" => "#{section.id}"})

    assert old_element == Repo.get!(Section, section.id).element
  end

  test "updating layout with incorrect user is not allowed" do
    user = user_fixture()
    [site] = user.sites
    {:ok, layout} = Layouts.create_layout(site, %{name: "basic"})

    {:error, :unauthorized} = Layouts.update(wrong_user(), layout, %{grid_template_rows: "foo"})
  end
end
