defmodule Affable.PagesTest do
  use Affable.DataCase, async: true
  alias Affable.Sites.Page
  alias Affable.Pages
  import Affable.SitesFixtures

  @valid_page %Page{title: "hi", path: "/"}

  test "can retrieve with host and path" do
    site = site_fixture()
    [homepage] = site.pages
    [domain] = site.domains
    page = Pages.get(domain.name, "/")

    assert homepage.id == page.id
  end

  test "attempting to retrieve with non-existent host returns nil"
  test "attempting to retrieve with non-existent path returns nil"

  test "colours can be set to valid values and get uppercased automatically" do
    changeset =
      @valid_page
      |> Page.changeset(%{
        "cta_background_colour" => "eEFF20",
        "cta_text_colour" => "012345",
        "header_background_colour" => "fF0000",
        "header_text_colour" => "00f000"
      })

    assert changeset.errors == []
    assert changeset.changes.cta_background_colour == "EEFF20"
    assert changeset.changes.cta_text_colour == "012345"
    assert changeset.changes.header_background_colour == "FF0000"
    assert changeset.changes.header_text_colour == "00F000"
  end

  test "colours can't be set to invalid values" do
    changeset =
      @valid_page
      |> Page.changeset(%{
        cta_background_colour: "01234",
        cta_text_colour: "GGGGGG",
        header_background_colour: "hi FFFFFF there"
      })

    assert {_, validation: :format} = changeset.errors[:cta_background_colour]
    assert {_, validation: :format} = changeset.errors[:cta_text_colour]
    assert {_, validation: :format} = changeset.errors[:header_background_colour]
  end

  test "paths must begin with a slash" do
    changeset =
      @valid_page
      |> Page.changeset(%{path: "foo"})

    assert {_, validation: :format} = changeset.errors[:path]
  end

  test "paths must not contain spaces" do
    changeset =
      @valid_page
      |> Page.changeset(%{path: "/foo bar"})

    assert {_, validation: :format} = changeset.errors[:path]
  end
end
