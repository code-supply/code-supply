defmodule Affable.PagesTest do
  use Affable.DataCase, async: true
  alias Affable.Sites.Page
  alias Affable.Pages
  import Affable.SitesFixtures

  @valid_page %Page{title: "hi", path: "/"}

  test "can retrieve with host and path, but not a bogus path" do
    site = site_fixture()
    [homepage] = site.pages
    [domain] = site.domains
    page = Pages.get(domain.name, "/")

    assert homepage.id == page.id

    assert nil == Pages.get(domain.name, "/not-a-path")
  end

  test "attempting to retrieve with non-existent host returns nil" do
    assert nil == Pages.get("not-a-real-host", "/")
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
