defmodule AffableWeb.AssetsLiveTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Affable.Accounts.User
  alias Affable.Sites

  setup context do
    {:ok, register_and_log_in_user(context)}
  end

  defp path(conn) do
    Routes.assets_path(conn, :index)
  end

  test "shows message when there are no assets for a site", %{
    conn: conn,
    user: %User{sites: [site]}
  } do
    Sites.remove_logo_and_header(site)

    {:ok, view, _html} = live(conn, path(conn))

    assert view
           |> element(".resources")
           |> render() =~ "No assets have been uploaded"
  end

  test "shows error when user doesn't provide a name or file", %{conn: conn} do
    {:ok, view, _html} = live(conn, path(conn))

    view
    |> element("#asset-form")
    |> render_submit()

    assert view |> has_element?(".invalid-feedback", "can't be blank")
  end

  test "can upload an image for one of the user's sites", %{
    conn: conn,
    user: %User{sites: [site1 | _]} = user
  } do
    {:ok, site2} = Affable.Sites.create_site(user, %{name: "site2"})

    {:ok, view, _html} = live(conn, path(conn))

    assert view |> has_element?("option", site1.name)
    assert view |> has_element?("option", site2.name)

    content = File.read!("test/support/fixtures/tiny.png")

    asset =
      file_input(view, "#asset-form", :asset, [
        %{
          name: "someimage.png",
          content: content,
          size: content |> :erlang.byte_size(),
          type: "image/png"
        }
      ])

    assert render_upload(asset, "someimage.png") =~ "100%"

    view
    |> element("#asset-form")
    |> render_submit(%{
      "asset" => %{
        "site_id" => "#{site1.id}",
        "name" => "Cool image"
      }
    })

    bucket = Application.fetch_env!(:affable, :bucket_name)

    site1_resources = view |> element("#resources-site#{site1.id}")
    site2_resources = view |> element("#resources-site#{site2.id}")

    assert site1_resources
           |> render() =~
             ~r(src="https://images.affable.app/nosignature/fill/[0-9]+/[0-9]+/sm/0/plain/gs://#{
               bucket
             }/.+")

    refute site1_resources
           |> render() =~ "No assets have been uploaded"

    assert site2_resources
           |> render() =~ "No assets have been uploaded"

    assert view |> has_element?("option", site1.name)
    assert view |> has_element?("option", site2.name)
  end
end
