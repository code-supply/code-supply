defmodule Affable.Sites.Raw do
  alias Affable.Sites.{Page, Site}
  alias Affable.Assets.Asset

  def raw(%Site{pages: pages} = site) do
    %{
      "id" => site.id,
      "name" => site.name,
      "made_available_at" => format_datetime(site.made_available_at),
      "pages" => pages |> Enum.map(&raw/1)
    }
  end

  def raw(%Page{} = page) do
    %{
      "title" => page.title,
      "path" => page.path
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
