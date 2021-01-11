defmodule AffableWeb.AssetsLiveTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Affable.Accounts.User

  setup context do
    {:ok, register_and_log_in_user(context)}
  end

  defp path(conn) do
    Routes.assets_path(conn, :index)
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
    user: %User{sites: [site | _]}
  } do
    {:ok, view, _html} = live(conn, path(conn))

    refute view |> has_element?(".resources > :first-child")

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
        "site_id" => "#{site.id}",
        "name" => "Cool image"
      }
    })

    assert view |> has_element?(".resources > :first-child")
  end
end
