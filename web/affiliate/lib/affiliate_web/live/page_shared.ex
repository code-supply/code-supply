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
      header_image_url: site["header_image_url"],
      name: site["name"],
      logo_url: site["site_logo_url"],
      subtitle: site["page_subtitle"],
      text: site["text"],
      items: items,
      attributes: attributes
    )
  end
end
