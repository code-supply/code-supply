defmodule Affable.SiteUpdaterTest do
  use Affable.DataCase
  import Hammox
  import Affable.SitesFixtures

  alias Phoenix.PubSub
  alias Affable.MockSiteClusterIO
  alias Affable.{Broadcaster, SiteUpdater}
  alias Affable.Sites.{Raw, Site}

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
    site = site_fixture()

    raw_site = %{
      preview: Raw.raw(site),
      published: Raw.raw(site)
    }

    stub(MockSiteClusterIO, :get_raw_site, fn ^site_id ->
      {:ok, raw_site}
    end)

    stub(MockSiteClusterIO, :set_available, fn _, _ -> {:ok, %Site{}} end)

    :ok = PubSub.broadcast(:affable, "testsiteupdater", site_name)

    assert_receive(^raw_site)
    |> write_fixture_for_external_consumption("site_update_message")
  end

  test "records when the site was first made available", %{site_id: site_id, site_name: site_name} do
    expect(MockSiteClusterIO, :set_available, fn ^site_id, _datetime ->
      {:ok, %Site{}}
    end)

    raw_site = Raw.raw(%Site{items: [], name: "must wait"})
    raw_site_representation = %{preview: raw_site, published: raw_site}

    stub(MockSiteClusterIO, :get_raw_site, fn ^site_id ->
      {:ok, raw_site_representation}
    end)

    :ok = PubSub.broadcast(:affable, "testsiteupdater", site_name)

    assert_receive ^raw_site_representation, 1000, nil
  end

  test "can broadcast on demand", %{site_id: site_id, broadcast_1: broadcast} do
    broadcast.(%{
      preview: Raw.raw(%Site{items: [], name: "Some Site", id: site_id}),
      published: Raw.raw(%Site{items: [], name: "Published Site", id: site_id})
    })

    assert_receive %{
      preview: %{"name" => "Some Site"},
      published: %{"name" => "Published Site"}
    }
  end

  defp write_fixture_for_external_consumption(obj, name) do
    (Path.dirname(__ENV__.file) <> "/../../../fixtures/#{name}.ex")
    |> File.write!(inspect(obj, pretty: true))
  end
end
