defmodule Affable.PagesTest do
  use Affable.DataCase, async: true

  alias Affable.Pages
  alias Affable.Sites.{Site, Page}

  import Affable.SitesFixtures

  @valid_page %Page{title: "hi", path: "/"}

  describe "when head element is present" do
    test "can strip the scripts and replace stylesheets with site's" do
      page = %Page{
        raw: """
        <html><head><link rel="stYLeSheEt" href="/some-styles.css"></head><script src="foo.js"></script><h1>Hi there!</h1></html>
        """
      }

      assert Pages.render(page, %Site{stylesheet: "* {}"}) ==
               ~s(<html><head><link rel="stylesheet" href="/stylesheets/app.css"/></head><h1>Hi there!</h1></html>)
    end
  end

  describe "when head element is not present" do
    test "can add the site's stylesheet" do
      page = %Page{
        raw: """
        <html><link rel="stYLeSheEt" href="/some-styles.css"><script src="foo.js"></script><h1>Hi there!</h1></html>
        """
      }

      assert Pages.render(page, %Site{stylesheet: "* {}"}) ==
               ~s(<html><head><link rel="stylesheet" href="/stylesheets/app.css"/></head><h1>Hi there!</h1></html>)
    end
  end

  describe "when stylesheet is blank" do
    test "doesn't render a link to a stylesheet" do
      page = %Page{
        raw: """
        <html><link rel="stYLeSheEt" href="/some-styles.css"><script src="foo.js"></script><h1>Hi there!</h1></html>
        """
      }

      assert Pages.render(page, %Site{stylesheet: ""}) ==
               ~s(<html><h1>Hi there!</h1></html>)
    end
  end

  test "can retrieve with host and path, but not a bogus path" do
    site = site_fixture()
    [homepage] = site.pages
    [domain] = site.domains
    page = Pages.get_for_route(domain.name, "/")

    assert homepage.id == page.id

    assert nil == Pages.get_for_route(domain.name, "/not-a-path")
  end

  test "attempting to retrieve with non-existent host returns nil" do
    assert nil == Pages.get_for_route("not-a-real-host", "/")
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
