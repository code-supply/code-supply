defmodule Affable.SiteUpdaterTest do
  use Affable.DataCase

  import Hammox

  alias Phoenix.PubSub
  alias Affable.MockSiteClusterIO
  alias Affable.{Broadcaster, SiteUpdater}
  alias Affable.Sites.{Attribute, AttributeDefinition, Item, Publication, Raw, Site}

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

  test "can broadcast appended resources", %{site_id: site_id, broadcast_1: broadcast} do
    item = %Item{
      site_id: site_id,
      name: "A great item",
      description: "A great description",
      image_url: "https://example.com/cool-image.jpeg",
      position: 11,
      url: "https://example.com/send-money.html",
      attributes: [
        %Attribute{
          value: "3.21",
          definition: %AttributeDefinition{name: "$", type: "dollar"}
        }
      ]
    }

    broadcast.(append: item)

    raw_item = Raw.raw(item)

    assert_receive(%{append: %{item: ^raw_item}})
    |> write_fixture_for_external_consumption("item_append_message")
  end

  test "can broadcast full site on demand", %{site_id: site_id, broadcast_1: broadcast} do
    broadcast.(%Site{
      id: site_id,
      items: [],
      name: "Some Site",
      latest_publication: %Publication{
        data: Raw.raw(%Site{items: [], name: "Published Site", id: site_id})
      }
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
