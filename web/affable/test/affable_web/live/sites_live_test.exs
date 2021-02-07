defmodule AffableWeb.SitesLiveTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Affable.Accounts.User
  alias Affable.Messages.WholeSite
  alias Affable.Sites.Raw

  setup context do
    {:ok, register_and_log_in_user(context)}
  end

  test "shows spinner until site is available", %{conn: conn, user: %User{sites: [site]}} do
    {:ok, view, _html} = live(conn, path(conn))

    assert view |> has_element?(".pending")

    raw_site =
      site
      |> Affable.Repo.preload(header_image: [], site_logo: [], items: [attributes: :definition])
      |> Raw.raw()
      |> Map.put("made_available_at", DateTime.utc_now())

    message =
      %WholeSite{preview: raw_site, published: raw_site}
      |> Map.from_struct()

    Phoenix.PubSub.broadcast(:affable, site.internal_name, message)

    refute view |> has_element?(".pending")
    assert view |> has_element?(".available")
  end

  defp path(conn) do
    AffableWeb.Router.Helpers.sites_path(conn, :index)
  end
end
