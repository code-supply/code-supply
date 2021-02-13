defmodule AffableWeb.SitesLiveTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Affable.Accounts.User

  setup context do
    {:ok, register_and_log_in_user(context)}
  end

  test "shows spinner until site is available", %{conn: conn, user: %User{sites: [site]}} do
    {:ok, view, _html} = live(conn, path(conn))

    assert view |> has_element?(".pending")

    made_available_at = DateTime.utc_now()

    Phoenix.PubSub.broadcast(:affable, site.internal_name, %{
      site
      | made_available_at: made_available_at
    })

    refute view |> has_element?(".pending")
    assert view |> has_element?(".available")
  end

  defp path(conn) do
    AffableWeb.Router.Helpers.sites_path(conn, :index)
  end
end
