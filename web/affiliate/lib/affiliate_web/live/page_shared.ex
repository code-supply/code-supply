defmodule AffiliateWeb.PageShared do
  import Phoenix.LiveView, only: [assign: 2]

  def assign_page(
        socket,
        site,
        %{
          "header_text" => header_text,
          "header_image_url" => header_image_url,
          "text" => text,
          "cta_text" => cta_text,
          "cta_background_colour" => cta_background_colour,
          "cta_text_colour" => cta_text_colour,
          "header_background_colour" => header_background_colour,
          "header_text_colour" => header_text_colour,
          "title" => title,
          "items" => items
        }
      ) do
    assign(socket,
      waiting: false,
      site_name: site["name"],
      page_title: title,
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
      attributes:
        case items do
          [%{"attributes" => attrs} | _] ->
            attrs

          _ ->
            []
        end
    )
  end

  def assign_page(socket, _site, nil) do
    waiting(socket)
  end

  def assign_path(socket, path_parts) do
    path = "/" <> Enum.join(path_parts, "/")
    assign(socket, path: path)
  end

  def assign_state(socket, _key, state) when state == %{preview: %{}, published: %{}} do
    waiting(socket)
  end

  def assign_state(%{assigns: %{path: path}} = socket, key, state) do
    site = state[key]
    pages = site["pages"]

    case pages |> Enum.find(&(&1["path"] == path)) do
      nil ->
        raise AffiliateWeb.PathNotStoredError, "Couldn't find #{path}"

      page ->
        assign_page(socket, site, page)
    end
  end

  defp waiting(socket) do
    assign(socket, waiting: true)
  end
end
