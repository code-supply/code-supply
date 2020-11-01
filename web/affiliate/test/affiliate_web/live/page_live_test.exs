defmodule AffiliateWeb.PageLiveTest do
  use AffiliateWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Phoenix.PubSub

  setup do
    start_supervised!({
      Affiliate.SiteState,
      {:affable, "testsite123", "testsiterequests"}
    })

    incoming_site = %{
      name: "My Awesome Affiliate Site",
      header_image_url: "",
      site_logo_url: "",
      page_subtitle: "",
      text: "",
      items: [
        %{
          position: 1,
          name: "",
          description: "",
          image_url: "",
          attributes: [
            %{
              name: "Price",
              value: "$1.23"
            }
          ],
          url: ""
        }
      ]
    }

    :ok = PubSub.broadcast(:affable, "testsite123", incoming_site)
  end

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Affiliate"
    assert render(page_live) =~ "Affiliate"
  end
end
