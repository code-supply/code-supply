defmodule HostingWeb.UploaderLiveTest do
  use HostingWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Hosting.Domains
  alias Hosting.Pages
  alias Hosting.Sites

  setup context do
    {:ok, register_and_log_in_user(context)}
  end

  test "can upload subdirs that have index.html, and they become pages that match on dir/", %{
    conn: conn,
    user: user
  } do
    [site] = user.sites
    site = Sites.get_site!(site)
    {:ok, domain} = Domains.create_domain(site, %{name: "my-domain.example.com"})

    {:ok, view, _html} = live(conn, url(~p"/sites/#{site.id}/uploader"))

    input =
      view
      |> file_input("#upload-form", :files, [
        %{
          name: "index.html",
          relative_path: "/some-dir/index.html",
          content: "<h1>Some cool dir</h1>",
          type: "text/html"
        }
      ])

    render_upload(input, "index.html")

    view
    |> element("#upload-form")
    |> render_submit()
    |> follow_redirect(conn, url(~p"/sites"))

    site = Sites.get_site!(site)
    [created_page] = site.pages

    found_page = Pages.get_for_route(domain.name, "/some-dir/")

    assert found_page.id == created_page.id
  end

  test "can update a site by uploading a directory with HTML / CSS", %{
    conn: conn,
    user: user
  } do
    [site] = user.sites
    site = Sites.get_site!(site)

    {:ok, view, _html} = live(conn, url(~p"/sites/#{site.id}/uploader"))

    input =
      view
      |> file_input("#upload-form", :files, [
        %{
          name: "index.html",
          relative_path: "index.html",
          content: "<h1>Home page</h1>",
          type: "text/html"
        },
        %{
          name: "contact.html",
          relative_path: "contact.html",
          content: "<h1>Contact me</h1>",
          type: "text/html"
        }
      ])

    render_upload(input, "index.html")
    render_upload(input, "contact.html")

    assets_before = site.assets
    page_paths_before = Enum.map(site.pages, & &1.path)

    assert page_paths_before == ~w(/)
    refute Enum.map(site.pages, & &1.raw) == ["<h1>Home page</h1>"]

    view
    |> element("#upload-form")
    |> render_submit()
    |> follow_redirect(conn, url(~p"/sites"))

    site = Sites.get_site!(site)
    page_paths_after = Enum.map(site.pages, & &1.path)

    assert site.assets == assets_before

    assert Enum.sort(page_paths_after) == Enum.sort(~w(/index.html /contact.html))

    assert Enum.map(site.pages, & &1.raw) == [
             "the static test fixture",
             "the static test fixture"
           ]
  end

  test "file types that aren't allowed are rejected", %{
    conn: conn,
    user: user
  } do
    content = ~s'document.write("hi")'

    [site] = user.sites
    site = Sites.get_site!(site)

    {:ok, view, _html} = live(conn, url(~p"/sites/#{site.id}/uploader"))

    input =
      view
      |> file_input("#upload-form", :files, [
        %{
          name: "app.js",
          content: content,
          type: "text/javascript"
        }
      ])

    input |> render_upload("app.js")

    asset_names_before = Enum.map(site.assets, & &1.name)

    view
    |> element("#upload-form")
    |> render_submit() =~ "Unacceptable"

    site = Sites.get_site!(site)
    assert Enum.map(site.assets, & &1.name) == asset_names_before
  end
end
