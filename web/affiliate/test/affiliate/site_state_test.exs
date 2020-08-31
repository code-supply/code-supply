defmodule Affiliate.SiteStateTest do
  use ExUnit.Case

  alias Phoenix.PubSub

  test "asks for content on startup" do
    PubSub.subscribe(:affable, "testsitestate")

    start_supervised!({
      Affiliate.SiteState,
      {:affable, "testsite:123", "testsitestate"}
    })

    assert_received "testsite:123"
  end

  describe "after startup" do
    setup do
      site_state =
        start_supervised!({
          Affiliate.SiteState,
          {:affable, "testsite:123", "testsitestate"}
        })

      %{site_state: site_state}
    end

    test "new content is stored and served", %{site_state: server} do
      incoming_site = %{
        name: "My Awesome Affiliate Site"
      }

      :ok = PubSub.broadcast(:affable, "testsite:123", incoming_site)

      assert GenServer.call(server, :get) == incoming_site
      assert GenServer.call(server, :get) == incoming_site
    end
  end
end
