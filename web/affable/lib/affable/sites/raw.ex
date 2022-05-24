defmodule Affable.Sites.Raw do
  alias Affable.Sites.{Page, Section, Site}
  alias Affable.Assets
  alias Affable.Assets.Asset
  alias Affable.Layouts.Layout

  def raw(%Site{layout: layout, pages: pages} = site) do
    %{
      "id" => site.id,
      "name" => site.name,
      "custom_head_html" => site.custom_head_html,
      "made_available_at" => format_datetime(site.made_available_at),
      "layout" => layout && raw(layout),
      "pages" => pages |> Enum.map(&raw/1)
    }
  end

  def raw(%Site{pages: []} = site) do
    raw(%{site | pages: [%Page{}]})
  end

  def raw(%Layout{
        grid_template_areas: grid_template_areas,
        grid_template_rows: grid_template_rows,
        grid_template_columns: grid_template_columns,
        sections: sections
      }) do
    %{
      "grid_template_areas" => grid_template_areas,
      "grid_template_rows" => grid_template_rows,
      "grid_template_columns" => grid_template_columns,
      "sections" => sections |> Enum.map(&raw/1)
    }
  end

  def raw(%Page{} = page) do
    %{
      "title" => page.title,
      "meta_description" => page.meta_description,
      "path" => page.path,
      "text" => page.text,
      "grid_template_areas" => page.grid_template_areas,
      "grid_template_rows" => page.grid_template_rows,
      "grid_template_columns" => page.grid_template_columns,
      "sections" => page.sections |> Enum.map(&raw/1)
    }
  end

  def raw(%Section{
        name: name,
        element: element,
        background_colour: background_colour,
        content: content,
        image: image
      }) do
    %{
      "name" => name,
      "element" => element,
      "background_colour" => background_colour,
      "content" => content,
      "image_url" =>
        image
        |> Assets.to_imgproxy_url(width: 567, height: 341, resizing_type: "fill"),
      "image_name" => if(image, do: image.name)
    }
  end

  def raw(%Asset{url: url, name: name}) do
    %{
      "url" => url,
      "name" => name
    }
  end

  defp format_datetime(datetime) do
    case datetime do
      nil -> nil
      dt -> dt |> DateTime.to_iso8601()
    end
  end
end
