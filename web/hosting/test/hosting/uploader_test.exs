defmodule Hosting.UploaderTest do
  use Hosting.DataCase, async: true

  import Hosting.AccountsFixtures

  alias Hosting.Sites
  alias Hosting.Uploader

  test "recording HTML makes pages but not assets" do
    user = user_fixture()
    [site] = user.sites

    multi =
      Ecto.Multi.new()
      |> Uploader.record(
        site: site,
        user: user,
        entry: %Phoenix.LiveView.UploadEntry{
          uuid: "a key",
          client_name: "stuff.html",
          client_type: "text/html"
        },
        params: %{},
        content: "the content"
      )

    site = Sites.get_site!(site)
    stylesheet_before = site.stylesheet
    assets_before = site.assets

    Hosting.Repo.transaction(multi)

    site = Sites.get_site!(site)
    assert "/stuff.html" in Enum.map(site.pages, & &1.path)
    assert site.assets == assets_before
    assert site.stylesheet == stylesheet_before
  end

  test "recording CSS only sets single stylesheet on site, for now" do
    user = user_fixture()
    [site] = user.sites

    multi =
      Ecto.Multi.new()
      |> Uploader.record(
        site: site,
        user: user,
        entry: %Phoenix.LiveView.UploadEntry{
          uuid: "a key",
          client_name: "app.css",
          client_type: "text/css"
        },
        params: %{},
        content: "the content"
      )
      |> Uploader.record(
        site: site,
        user: user,
        entry: %Phoenix.LiveView.UploadEntry{
          uuid: "another key",
          client_name: "another.css",
          client_type: "text/css"
        },
        params: %{},
        content: "should be ignored"
      )

    site = Sites.get_site!(site)
    assets_before = site.assets
    pages_before = Sites.with_pages(site).pages

    Hosting.Repo.transaction(multi)

    site = Sites.get_site!(site)

    assert site.stylesheet == "the content"
    assert site.pages == pages_before
    assert site.assets == assets_before
  end

  test "recording invalid upload doesn't make asset, page or stylesheet" do
    user = user_fixture()
    [site] = user.sites

    multi =
      Uploader.record(
        Ecto.Multi.new(),
        site: site,
        user: user,
        entry: %Phoenix.LiveView.UploadEntry{
          uuid: "a key",
          client_name: "",
          client_type: "image/jpeg"
        },
        params: %{},
        content: nil
      )

    site = Sites.get_site!(site)
    assets_before = site.assets
    pages_before = Sites.with_pages(site).pages
    stylesheet_before = site.stylesheet

    Hosting.Repo.transaction(multi)

    site = Sites.get_site!(site)

    assert site.pages == pages_before
    assert site.assets == assets_before
    assert site.stylesheet == stylesheet_before
  end

  test "can strip the root directory from relative paths" do
    assert Uploader.strip_root("") == ""
    assert Uploader.strip_root("index.html") == "index.html"
    assert Uploader.strip_root("dist/index.html") == "index.html"
    assert Uploader.strip_root("dist/foo/bar/index.html") == "foo/bar/index.html"
  end

  test "can group directory content by file type" do
    entries = [
      css = %Phoenix.LiveView.UploadEntry{
        valid?: false,
        done?: false,
        cancelled?: false,
        client_name: "app.css",
        client_relative_path: "dist/app.css",
        client_size: 4933,
        client_type: "text/css",
        client_last_modified: 1_675_815_380_495
      },
      cv_html = %Phoenix.LiveView.UploadEntry{
        valid?: true,
        done?: false,
        cancelled?: false,
        client_name: "cv.html",
        client_relative_path: "dist/cv.html",
        client_size: 7319,
        client_type: "text/html",
        client_last_modified: 1_678_146_414_881
      },
      contact_html = %Phoenix.LiveView.UploadEntry{
        valid?: true,
        done?: false,
        cancelled?: false,
        client_name: "contact.html",
        client_relative_path: "dist/contact.html",
        client_size: 1614,
        client_type: "text/html",
        client_last_modified: 1_678_146_414_881
      },
      index_html = %Phoenix.LiveView.UploadEntry{
        valid?: true,
        done?: false,
        cancelled?: false,
        client_name: "index.html",
        client_relative_path: "dist/index.html",
        client_size: 2176,
        client_type: "text/html",
        client_last_modified: 1_678_146_414_881
      },
      png = %Phoenix.LiveView.UploadEntry{
        valid?: true,
        done?: false,
        cancelled?: false,
        client_name: "bottoms.png",
        client_relative_path: "dist/bottoms.png",
        client_size: 2176,
        client_type: "image/png",
        client_last_modified: 1_678_146_414_881
      },
      svg = %Phoenix.LiveView.UploadEntry{
        valid?: true,
        done?: false,
        cancelled?: false,
        client_name: "faces.svg",
        client_relative_path: "dist/faces.svg",
        client_size: 2176,
        client_type: "image/svg",
        client_last_modified: 1_678_146_414_881
      },
      json = %Phoenix.LiveView.UploadEntry{
        valid?: true,
        done?: false,
        cancelled?: false,
        client_name: "config.json",
        client_relative_path: "dist/config.json",
        client_size: 2176,
        client_type: "application/json",
        client_last_modified: 1_678_146_414_881
      }
    ]

    assert Uploader.group_directory_entries(entries) == [
             {"HTML", [cv_html, contact_html, index_html]},
             {"CSS", [css]},
             {"Images", [png, svg]},
             {"Other", [json]}
           ]
  end
end
