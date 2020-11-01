defmodule Affable.Sites.Raw do
  alias Affable.Sites.{Site, Item, AttributeDefinition, Attribute}

  def raw(%Site{} = site) do
    %{
      id: site.id,
      name: site.name,
      site_logo_url: site.site_logo_url,
      page_subtitle: site.page_subtitle,
      header_image_url: site.header_image_url,
      text: site.text,
      made_available_at: site.made_available_at,
      items: site.items |> Enum.map(&raw/1)
    }
  end

  def raw(%Item{} = item) do
    %{
      description: item.description,
      image_url: item.image_url,
      name: item.name,
      position: item.position,
      url: item.url,
      attributes: item.attributes |> Enum.map(&raw/1)
    }
  end

  def raw(%Attribute{
        value: value,
        definition: %AttributeDefinition{name: name, type: type}
      }) do
    %{
      name: name,
      value:
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
end
