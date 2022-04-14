defmodule Affable.SectionsTest do
  use Affable.DataCase, async: true

  import Affable.{AccountsFixtures, SitesFixtures}

  alias Affable.Sites
  alias Affable.Sites.Section
  alias Affable.Layouts
  alias Affable.Sections

  test "names are a-z, 0-9 or dash, nothing else" do
    name = fn s -> Section.changeset(%Section{}, %{name: s}) end

    assert name.("hithere").valid?
    assert name.("hi-there").valid?

    refute name.("Hithere").valid?
    refute name.("with_underscores").valid?
    refute name.("with spaces").valid?
  end

  test "colours can be set to valid values and get uppercased automatically" do
    changeset =
      %Section{}
      |> Section.changeset(%{
        "name" => "validname",
        "background_colour" => "fF0000",
        "text_colour" => "00f000"
      })

    assert changeset.errors == []
    assert changeset.changes.background_colour == "FF0000"
    assert changeset.changes.text_colour == "00F000"
  end

  test "colours can't be set to invalid values" do
    changeset =
      %Section{}
      |> Section.changeset(%{
        name: "validname",
        background_colour: "01234",
        text_colour: "GGGGGG"
      })

    assert {_, validation: :format} = changeset.errors[:background_colour]
    assert {_, validation: :format} = changeset.errors[:text_colour]
  end

  test "can retrieve a layout section only as correct user" do
    user = user_fixture()
    site = site_fixture(user)
    {:ok, layout} = Layouts.create_layout(site, %{name: "my layout"})
    [%Section{id: id, name: name} | _] = layout.sections
    section = Sections.get!(user, id)
    assert section.name == name

    assert_raise Ecto.NoResultsError, fn ->
      Sections.get!(wrong_user(), id)
    end
  end

  test "can retrieve a page section only as correct user" do
    user = user_fixture()
    site = site_fixture(user)
    [page | _] = site.pages
    {:ok, page} = Sites.add_page_section(page, user)
    [%Section{id: id, name: name} | _] = page.sections
    section = Sections.get!(user, id)
    assert section.name == name

    assert_raise Ecto.NoResultsError, fn ->
      Sections.get!(wrong_user(), id)
    end
  end

  test "can update a section (must get! first for auth)" do
    user = user_fixture()
    site = site_fixture(user)
    {:ok, layout} = Layouts.create_layout(site, %{name: "my layout"})
    [section | _] = layout.sections

    {:ok, _site} = Sites.update_site(site, %{layout_id: layout.id})

    {:ok, section} = Sections.update(section, %{name: "anewname"})

    assert "anewname" == section.name
    assert "anewname" == Sections.get!(user, section.id).name
  end

  test "can delete a section" do
    user = user_fixture()
    site = site_fixture(user)
    {:ok, layout} = Layouts.create_layout(site, %{name: "my layout"})
    [section | _] = layout.sections

    {:ok, _site} = Sites.update_site(site, %{layout_id: layout.id})

    :ok = Sections.delete(section)

    reloaded_layout = Layouts.get!(user, layout.id)

    refute reloaded_layout.grid_template_areas =~ ~r/#{section.name}/s
  end
end
