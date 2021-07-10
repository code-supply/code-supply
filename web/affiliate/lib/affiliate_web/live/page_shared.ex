defmodule AffiliateWeb.PageShared do
  import Phoenix.LiveView, only: [assign: 2]

  def assign_site(socket, site) do
    items = Map.get(site, "items", [])

    attributes =
      items
      |> Enum.reduce_while([], fn item, _acc ->
        {:halt, item["attributes"]}
      end)

    assign(socket,
      page_title: site["name"],
      custom_head_html: site["custom_head_html"],
      header_image_url: site["header_image_url"],
      name: site["name"],
      logo_url: site["site_logo_url"],
      text: site["text"],
      cta_text: site["cta_text"],
      cta_background_colour: site["cta_background_colour"],
      cta_text_colour: site["cta_text_colour"],
      header_background_colour: site["header_background_colour"],
      header_text_colour: site["header_text_colour"],
      items: items,
      attributes: attributes
    )
  end
end
