defmodule Affable.Sites.Raw do
  alias Affable.Sites.{Site, Item, AttributeDefinition, Attribute}
  alias Affable.Assets

  def raw(%Site{site_logo: site_logo, header_image: header_image} = site) do
    %{
      "id" => site.id,
      "name" => site.name,
      "site_logo_url" => site_logo |> Assets.to_imgproxy_url(width: 600, height: 176),
      "page_subtitle" => site.page_subtitle,
      "header_image_url" =>
        header_image |> Assets.to_imgproxy_url(width: 567, height: 341, resizing_type: "fill"),
      "text" => site.text,
      "cta_text" => site.cta_text,
      "cta_background_colour" => site.cta_background_colour,
      "cta_text_colour" => site.cta_text_colour,
      "made_available_at" => format_datetime(site.made_available_at),
      "items" => site.items |> Enum.map(&raw/1)
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
