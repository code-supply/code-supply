defmodule Affiliate.SiteStateTest do
  use ExUnit.Case

  import Affiliate.Fixtures

  alias Phoenix.PubSub
  alias Affiliate.SiteState

  test "asks for content on startup" do
    PubSub.subscribe(:affable, "testsiterequests")

    start_supervised!({
      Affiliate.SiteState,
      {:affable, "testsite123", "testsiterequests"}
    })

    assert_received "testsite123"
  end

  describe "after startup" do
    setup do
      site_state =
        start_supervised!({
          SiteState,
          {:affable, "testsite123", "testsiterequests"}
        })

      %{site_state: site_state}
    end

    test "serves a compatible default map" do
      assert Map.keys(SiteState.get()) == Map.keys(fixture("site_update_message"))
    end

    test "replacement content is stored and served" do
      incoming_payload = fixture("site_update_message")

      :ok = PubSub.broadcast(:affable, "testsite123", incoming_payload)

      assert SiteState.get() == incoming_payload
      assert SiteState.get() == incoming_payload
    end

    test "appended content is stored and served" do
      :ok = PubSub.broadcast(:affable, "testsite123", fixture("site_update_message"))

      items_before = SiteState.get().preview["items"]

      incoming_payload = fixture("item_append_message")

      :ok = PubSub.broadcast(:affable, "testsite123", incoming_payload)

      items_after = SiteState.get().preview["items"]

      assert length(items_after) == length(items_before) + 1
    end

    test "can get subscription info" do
      assert SiteState.subscription_info() == {:affable, "testsite123"}
    end
  end
end
