defmodule Hosting.PagesTest do
  use Hosting.DataCase, async: true

  alias Hosting.Pages
  alias Hosting.Sites
  alias Hosting.Sites.{Page, Site}

  import Hosting.AccountsFixtures
  import Hosting.SitesFixtures

  @valid_page %Page{title: "hi", path: "/"}
  @irrelevant_datetime ~U[2001-01-01 00:00:00Z]

  test "preserves whitespace inside <pre> tabs" do
    page = %Page{
      raw: ~s(<pre><span>   </span></pre>)
    }

    assert Pages.render(page, %Site{}, @irrelevant_datetime) =~ "<pre><span>   </span></pre>"
  end

  describe "dynamic" do
    test "replacement of year" do
      page = %Page{
        raw: """
        <html><p data-dynamic="year"></html>
        """
      }

      assert Pages.render(page, %Site{}, ~U[1983-04-25 03:00:00Z]) =~
               ~r(<p data-dynamic="year">1983</p>)
    end
  end

  describe "when head element is present" do
    test "strips scripts and replaces site stylesheets with DB stylesheets, leaving external web stylesheets intact" do
      page = %Page{
        raw: """
        <html>
        <head>
        <link rel="stYLeSheEt" href="/some-styles.css">
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta/css/bootstrap.min.css">
        </head>
        <script src="foo.js"></script>
        <h1>Hi there!</h1>
        </html>
        """
      }

      assert Pages.render(page, %Site{stylesheet: "* {}"}, @irrelevant_datetime) ==
               """
               <html><head><link rel="stylesheet" href="/stylesheets/app.css"/>

               <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-beta/css/bootstrap.min.css"/>
               </head>

               <body><h1>Hi there!</h1>

               </body></html>
               """
               |> String.trim_trailing("\n")
    end
  end

  describe "when head element is not present" do
    test "can add the site's stylesheet" do
      page = %Page{
        raw: """
        <html><link rel="stYLeSheEt" href="/some-styles.css"><script src="foo.js"></script><h1>Hi there!</h1></html>
        """
      }

      assert Pages.render(page, %Site{stylesheet: "* {}"}, @irrelevant_datetime) ==
               ~s(<html><head><link rel="stylesheet" href="/stylesheets/app.css"/></head><body><h1>Hi there!</h1>\n</body></html>)
    end
  end

  describe "when stylesheet is blank" do
    test "doesn't render a link to a stylesheet" do
      page = %Page{
        raw: """
        <html><link rel="stYLeSheEt" href="/some-styles.css"><script src="foo.js"></script><h1>Hi there!</h1></html>
        """
      }

      assert Pages.render(page, %Site{stylesheet: ""}, @irrelevant_datetime) ==
               ~s(<html><head></head><body><h1>Hi there!</h1>\n</body></html>)
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

  test "can retrieve pages without html suffix" do
    user = user_fixture()
    site = site_fixture(user)
    [homepage] = site.pages

    {:ok, homepage} =
      Sites.update_page(
        homepage,
        %{path: "/index.html"},
        user
      )

    {:ok, new_page} = Sites.add_page(site, user)

    {:ok, new_page} =
      Sites.update_page(
        new_page,
        %{path: "/untitled-page.html"},
        user
      )

    [domain] = site.domains

    assert homepage.id == Pages.get_for_route(domain.name, "/").id
    assert new_page.id == Pages.get_for_route(domain.name, "/untitled-page").id
  end

  test "renders index.html links as /" do
    rendered =
      Pages.render(
        %Page{
          raw: """
          nonsense
          <a href="donttouch.zip">a zip file</a>
          <a href="index.html">Home</a>
          <a href="index.html#some-place">Inside the home</a>
          more nonsense
          """
        },
        %Site{stylesheet: ""},
        @irrelevant_datetime
      )

    assert rendered =~ ~s(<a href="/">Home</a>)
    assert rendered =~ ~s(<a href="/#some-place">Inside the home</a>)
    assert rendered =~ ~s(<a href="donttouch.zip">a zip file</a>)
  end

  test "renders blah.html as /blah" do
    rendered =
      Pages.render(
        %Page{
          raw: """
          nonsense
          <a href="donttouch.zip">a zip file</a>
          <a href="http://www.example.com/donttouch.zip">another zip file</a>
          <a href="contact.html">Contact</a>
          <a href="contact.html#email">Contact by email</a>
          more nonsense
          """
        },
        %Site{stylesheet: ""},
        @irrelevant_datetime
      )

    assert rendered =~ ~s(<a href="/contact">Contact</a>)
    assert rendered =~ ~s(<a href="/contact#email">Contact by email</a>)
    assert rendered =~ ~s(<a href="donttouch.zip">a zip file</a>)
    assert rendered =~ ~s(<a href="http://www.example.com/donttouch.zip">another zip file</a>)
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
