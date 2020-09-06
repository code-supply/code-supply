defmodule Affable.SiteUpdaterTest do
  use ExUnit.Case
  import Hammox

  alias Phoenix.PubSub
  alias Affable.MockSiteClusterIO
  alias Affable.{Broadcaster, SiteUpdater}
  alias Affable.Sites.Site

  setup :set_mox_from_context
  setup :verify_on_exit!

  setup do
    site_id = 1_234_567
    site_name = Affable.ID.site_name_from_id(site_id)

    PubSub.subscribe(:affable, site_name)

    server =
      start_supervised!({
        SiteUpdater,
        {MockSiteClusterIO, :affable, "testsiteupdater"}
      })

    Hammox.protect(
      SiteUpdater,
      Broadcaster,
      broadcast: 1
    )
    |> Map.merge(%{server: server, site_id: site_id, site_name: site_name})
  end

  test "responds to requests for content with a broadcast back for the site", %{
    site_id: site_id,
    site_name: site_name
  } do
    stub(MockSiteClusterIO, :get_raw_site, fn ^site_id ->
      {:ok, %{name: "Some Site", made_available_at: DateTime.utc_now()}}
    end)

    stub(MockSiteClusterIO, :set_available, fn _, _ -> {:ok, %Site{}} end)

    :ok = PubSub.broadcast(:affable, "testsiteupdater", site_name)

    assert_receive %{name: "Some Site", made_available_at: _}
  end

  test "records when the site was first made available", %{site_id: site_id, site_name: site_name} do
    expect(MockSiteClusterIO, :set_available, fn ^site_id, _datetime ->
      {:ok, %Site{}}
    end)

    stub(MockSiteClusterIO, :get_raw_site, fn ^site_id ->
      {:ok, %{name: "must wait"}}
    end)

    :ok = PubSub.broadcast(:affable, "testsiteupdater", site_name)

    assert_receive %{name: "must wait"}, 1000, nil
  end

  test "can broadcast on demand", %{site_id: site_id, broadcast_1: broadcast} do
    broadcast.(%{name: "Some Site", id: site_id})

    assert_receive %{name: "Some Site"}
  end
end
