defmodule AffiliateWeb.PageShared do
  import Phoenix.LiveView, only: [assign: 2]
  import Access, only: [at: 1, key: 2]

  def assign_site(socket, site) do
    items = get_in(site, [key("pages", []), at(0), "items"]) || []
    attributes = get_in(items, [at(0), "attributes"])

    case site["pages"] do
      [
        %{
          "title" => page_title,
          "header_text" => header_text,
          "header_image_url" => header_image_url,
          "text" => text,
          "cta_text" => cta_text,
          "cta_background_colour" => cta_background_colour,
          "cta_text_colour" => cta_text_colour,
          "header_background_colour" => header_background_colour,
          "header_text_colour" => header_text_colour
        }
        | _
      ] ->
        assign(socket,
          waiting: false,
          site_name: site["name"],
          title: page_title,
          custom_head_html: site["custom_head_html"],
          header_image_url: header_image_url,
          text: text,
          header_text: header_text,
          logo_url: site["site_logo_url"],
          cta_text: cta_text,
          cta_background_colour: cta_background_colour,
          cta_text_colour: cta_text_colour,
          header_background_colour: header_background_colour,
          header_text_colour: header_text_colour,
          items: items,
          attributes: attributes
        )

      nil ->
        assign(socket, waiting: true)
    end
  end
end
