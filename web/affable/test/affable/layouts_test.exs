defmodule Affable.LayoutsTest do
  use Affable.DataCase, async: true

  import Affable.SitesFixtures

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
end
