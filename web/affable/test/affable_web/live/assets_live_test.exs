defmodule AffableWeb.AssetsLiveTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Affable.Accounts.User
  alias Affable.Sites
  alias Affable.Sites.Site

  @content File.read!("test/support/fixtures/tiny.png")

  setup context do
    {:ok, register_and_log_in_user(context)}
  end

  test "shows message when there are no assets for a site", %{
    conn: conn,
    user: %User{} = user
  } do
    {:ok, _site} = Sites.create_bare_site(user, %{name: "site2"})

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

  defp assert_sites_selectable(view, sites) do
    for site <- sites do
      assert view |> has_element?("option", site.name)
    end
  end

  test "can upload and delete images", %{
    conn: conn,
    user: %User{sites: [site1 | _]} = user
  } do
    {:ok, site2} = Affable.Sites.create_bare_site(user, %{name: "site2"})
    {:ok, view, _html} = live(conn, path(conn))

    site1_resources = view |> element("#resources-site#{site1.id}")
    site2_resources = view |> element("#resources-site#{site2.id}")

    refute site1_resources |> render() =~ successful_upload_pattern()

    view |> assert_sites_selectable([site1, site2])

    assert view
           |> asset_input_for("someimage.png")
           |> render_upload("someimage.png") =~ "100%"

    view |> render_asset_submit(site1, "Upload One")

    assert site1_resources |> render() =~ successful_upload_pattern()
    assert site2_resources |> render() =~ no_images_uploaded_pattern()

    refute site1_resources |> render() =~ no_images_uploaded_pattern()

    view |> assert_sites_selectable([site1, site2])

    view
    |> element("#resources-site#{site1.id} .trash")
    |> render_click()

    site1_resources_html = site1_resources |> render()
    refute site1_resources_html =~ successful_upload_pattern()
    refute site1_resources_html =~ "Upload One"

    assert view
           |> asset_input_for("someotherimage.png")
           |> render_upload("someotherimage.png") =~ "100%"

    refute view
           |> render_asset_submit(site1, "Upload Two") =~ "Upload One"
  end

  defp render_asset_submit(view, site, name) do
    view
    |> element("#asset-form")
    |> render_submit(%{
      "asset" => %{
        "site_id" => "#{site.id}",
        "name" => name
      }
    })
  end

  defp asset_input_for(view, name) do
    file_input(view, "#asset-form", :asset, [
      %{
        name: name,
        content: @content,
        size: @content |> :erlang.byte_size(),
        type: "image/png"
      }
    ])
  end

  test "informs the user when an asset is in use", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, path(conn))

    %User{sites: [%Site{site_logo_id: asset_id}]} = user

    refute view
           |> has_element?("#delete-asset-#{asset_id}")

    assert view
           |> has_element?("#asset-in-use-#{asset_id}")
  end

  defp path(conn) do
    Routes.assets_path(conn, :index)
  end

  defp successful_upload_pattern() do
    ~r(src="https://images.affable.app/nosignature/fill/[0-9]+/[0-9]+/ce/0/plain/gs://#{
      Application.fetch_env!(:affable, :bucket_name)
    }/.+")
  end

  defp no_images_uploaded_pattern() do
    "No assets have been uploaded"
  end
end
