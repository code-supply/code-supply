defmodule AffiliateWeb.PageShared do
  import Phoenix.LiveView, only: [assign: 2]
  import Access, only: [at: 1, key: 2]

  def assign_site(socket, site) do
    items = get_in(site, [key("pages", []), at(0), "items"]) || []
    attributes = get_in(items, [at(0), "attributes"])

    {page_title, header_text, text} =
      case site["pages"] do
        [
          %{
            "title" => page_title,
            "header_text" => header_text,
            "text" => text
          }
        ] ->
          {page_title, header_text, text}

        nil ->
          {"Waiting for data", "", ""}
      end

    assign(socket,
      site_name: site["name"],
      title: page_title,
      custom_head_html: site["custom_head_html"],
      header_image_url: site["header_image_url"],
      text: text,
      header_text: header_text,
      logo_url: site["site_logo_url"],
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
