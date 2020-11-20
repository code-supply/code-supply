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

    test "new content is stored and served" do
      incoming_payload = site_update_message()

      :ok = PubSub.broadcast(:affable, "testsite123", incoming_payload)

      assert SiteState.get() == incoming_payload
      assert SiteState.get() == incoming_payload
    end

    test "can get subscription info" do
      assert SiteState.subscription_info() == {:affable, "testsite123"}
    end
  end
end
