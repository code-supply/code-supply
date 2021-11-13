defmodule Affable.Sites.Raw do
  alias Affable.Sites.{Page, Section, Site, Item, AttributeDefinition, Attribute}
  alias Affable.Assets

  def raw(
        %Site{
          site_logo: site_logo,
          pages: pages
        } = site
      ) do
    %{
      "id" => site.id,
      "name" => site.name,
      "site_logo_url" => site_logo |> Assets.to_imgproxy_url(width: 600, height: 176),
      "custom_head_html" => site.custom_head_html,
      "made_available_at" => format_datetime(site.made_available_at),
      "pages" => pages |> Enum.map(&raw/1)
    }
  end

  def raw(%Site{pages: []} = site) do
    raw(%{site | pages: [%Page{header_image: nil}]})
  end

  def raw(%Page{} = page) do
    %{
      "title" => page.title,
      "meta_description" => page.meta_description,
      "path" => page.path,
      "header_text" => page.header_text,
      "header_background_colour" => page.header_background_colour,
      "header_text_colour" => page.header_text_colour,
      "header_image_url" =>
        page.header_image
        |> Assets.to_imgproxy_url(width: 567, height: 341, resizing_type: "fill"),
      "text" => page.text,
      "cta_background_colour" => page.cta_background_colour,
      "cta_text_colour" => page.cta_text_colour,
      "cta_text" => page.cta_text,
      "items" => page.items |> Enum.map(&raw/1),
      "sections" => page.sections |> Enum.map(&raw/1)
    }
  end

  def raw(%Section{
        name: name,
        element: element,
        background_colour: background_colour
      }) do
    %{
      "name" => name,
      "element" => element,
      "background_colour" => background_colour
    }
  end

  def raw(%Item{image: image} = item) do
    %{
      "description" => item.description,
      "image_url" => image |> Assets.to_imgproxy_url(),
      "name" => item.name,
      "position" => item.position,
      "url" => item.url,
      "attributes" => item.attributes |> Enum.map(&raw/1)
    }
  end

  def raw(%Attribute{
        value: value,
        definition: %AttributeDefinition{name: name, type: type}
      }) do
    %{
      "name" => name,
      "value" =>
        case {value, type} do
          {nil, _} ->
            ""

          {"", _} ->
            ""

          {_, "dollar"} ->
            "$#{value}"

          {_, "pound"} ->
            "£#{value}"

          {_, "euro"} ->
            "€#{value}"

          _ ->
            value
        end
    }
  end

  defp format_datetime(datetime) do
    case datetime do
      nil -> nil
      dt -> dt |> DateTime.to_iso8601()
    end
  end
end
