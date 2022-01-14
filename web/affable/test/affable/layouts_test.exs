defmodule Affable.LayoutsTest do
  use Affable.DataCase, async: true

  import Affable.SitesFixtures
  import Affable.AccountsFixtures

  alias Affable.Layouts

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

  test "resizing a section causes layout to shift" do
    user = user_fixture()
    [site] = user.sites
    {:ok, layout} = Layouts.create_layout(site, %{name: "basic"})
    [original_x, _] = layout.grid_template_columns |> String.split(" ")
    {:ok, layout} = Layouts.resize(user, layout, section_name: "main", x: original_x, y: "100")

    [reloaded_layout] = Layouts.all()

    assert layout.grid_template_rows == "50px 100px 50px"
    assert reloaded_layout == layout
  end

  test "resizing with incorrect user is not allowed" do
    user = user_fixture()
    [site] = user.sites
    {:ok, layout} = Layouts.create_layout(site, %{name: "basic"})

    {:error, :unauthorized} =
      Layouts.resize(wrong_user(), layout, section_name: "main", x: "1", y: "2")
  end
end
