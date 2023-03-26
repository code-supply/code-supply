defmodule AffableWeb.UploaderLiveTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Affable.Assets

  setup context do
    {:ok, register_and_log_in_user(context)}
  end

  test "can update a site by uploading a directory with HTML / CSS", %{
    conn: conn,
    user: user
  } do
    content = "<html><h1>Hi there</h1></html>"

    [site] = user.sites

    {:ok, view, _html} = live(conn, url(~p"/sites/#{site.id}/uploader"))

    input =
      view
      |> file_input("#upload-form", :files, [
        %{
          name: "index.html",
          content: content,
          size: :erlang.byte_size(content),
          type: "text/html"
        },
        %{
          name: "contact.html",
          content: content,
          type: "text/html"
        }
      ])

    input |> render_upload("index.html")
    input |> render_upload("contact.html")

    names_before = all_asset_names_and_site_ids()

    refute {"index.html", site.id} in names_before
    refute {"contact.html", site.id} in names_before

    view
    |> element("#upload-form")
    |> render_submit()
    |> follow_redirect(conn, url(~p"/sites"))

    names_after = all_asset_names_and_site_ids()

    assert {"index.html", site.id} in names_after
    assert {"contact.html", site.id} in names_after
  end

  test "file types that aren't allowed are rejected", %{
    conn: conn,
    user: user
  } do
    content = ~s'document.write("hi")'

    [site] = user.sites

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

    names_before = all_asset_names_and_site_ids()

    view
    |> element("#upload-form")
    |> render_submit() =~ "Unacceptable"

    assert all_asset_names_and_site_ids() == names_before
  end

  defp all_asset_names_and_site_ids() do
    for asset <- Affable.Repo.all(Assets.default_query()) do
      {asset.name, asset.site_id}
    end
  end
end
