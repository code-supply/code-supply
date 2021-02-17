defmodule AffableWeb.AssetsLiveTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Affable.Accounts.User
  alias Affable.Assets.Asset
  alias Affable.Sites
  alias Affable.Repo

  setup context do
    {:ok, register_and_log_in_user(context)}
  end

  defp path(conn) do
    Routes.assets_path(conn, :index)
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

  test "can upload and delete an image for one of the user's sites", %{
    conn: conn,
    user: %User{sites: [site1 | _]} = user
  } do
    {:ok, site2} = Affable.Sites.create_bare_site(user, %{name: "site2"})
    {:ok, view, _html} = live(conn, path(conn))

    site1_resources = view |> element("#resources-site#{site1.id}")
    site2_resources = view |> element("#resources-site#{site2.id}")

    refute site1_resources |> render() =~ dev_bucket_uploaded_pattern()

    view |> assert_sites_selectable([site1, site2])

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

    assert site1_resources |> render() =~ dev_bucket_uploaded_pattern()
    refute site1_resources |> render() =~ no_images_uploaded_pattern()
    assert site2_resources |> render() =~ no_images_uploaded_pattern()

    view |> assert_sites_selectable([site1, site2])

    %Asset{} =
      asset =
      (site1 |> Repo.preload(:assets)).assets
      |> Enum.find(fn a ->
        a.name == "Cool image"
      end)

    view
    |> element("#delete-asset-#{asset.id}")
    |> render_click()

    refute site1_resources |> render() =~ dev_bucket_uploaded_pattern()
  end

  defp dev_bucket_uploaded_pattern() do
    ~r(src="https://images.affable.app/nosignature/auto/[0-9]+/[0-9]+/sm/0/plain/gs://#{
      Application.fetch_env!(:affable, :bucket_name)
    }/.+")
  end

  defp no_images_uploaded_pattern() do
    "No assets have been uploaded"
  end
end
