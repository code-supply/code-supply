defmodule Affiliate.SiteStateTest do
  use ExUnit.Case

  import Affiliate.Fixtures
  import Hammox

  alias Phoenix.PubSub
  alias Affiliate.SiteState
  alias Affiliate.MockHTTP

  setup :verify_on_exit!
  setup :set_mox_global

  test "retrieves content on startup" do
    MockHTTP
    |> expect(:get, fn "http://some.preview.url/" ->
      {:ok, %{"name" => "preview site"}}
    end)
    |> expect(:get, fn "http://some.published.url/" ->
      {:ok, %{"name" => "published site"}}
    end)

    start_supervised!({
      SiteState,
      {"http://some.preview.url/", "http://some.published.url/"}
    })

    assert SiteState.get() == %{
             preview: %{"name" => "preview site"},
             published: %{"name" => "published site"}
           }
  end

  test "replacement content is stored, served and broadcasted" do
    stub(MockHTTP, :get, fn _ -> {:ok, %{}} end)

    start_supervised!({
      SiteState,
      {"http://some.preview.url/", "http://some.published.url/"}
    })

    assert SiteState.get().preview == %{}

    incoming_payload = fixture("site_update_message")

    :ok = PubSub.subscribe(Affiliate.PubSub, "updates")

    SiteState.store(incoming_payload)

    assert incoming_payload["preview"] != %{}

    expected_payload = %{
      preview: incoming_payload["preview"],
      published: incoming_payload["published"]
    }

    assert SiteState.get() == expected_payload
    assert SiteState.get() == expected_payload
    assert_receive ^expected_payload
  end
end
