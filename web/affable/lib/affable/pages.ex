defmodule Affable.Pages do
  import Ecto.Query, warn: false

  alias Affable.Repo
  alias Affable.Sites.{Site, Page}

  @site_stylesheet {"link",
                    [
                      {"rel", "stylesheet"},
                      {"href", "/stylesheets/app.css"}
                    ], []}

  def render(page, %Site{stylesheet: stylesheet}) do
    process(page, stylesheet)
    |> Floki.raw_html()
  end

  defp process(%Page{raw: raw}, "") do
    {:ok, doc} = Floki.parse_document(raw)

    doc
    |> Floki.filter_out("script")
    |> Floki.filter_out("link[rel=stylesheet i]")
  end

  defp process(%Page{} = page, _stylesheet_present) do
    process(page, "")
    |> Floki.traverse_and_update(fn
      {"html", _attrs, [{"head", _, _} | _]} = html ->
        html

      {"html", attrs, children_no_head} ->
        {"html", attrs, [{"head", [], [@site_stylesheet]} | children_no_head]}

      {"head", attrs, children} ->
        {"head", attrs, [@site_stylesheet | children]}

      other ->
        other
    end)
  end

  def get_for_route(host, path) do
    suffixed_path = add_html_suffix(path)

    Repo.one(
      from(p in Page,
        join: s in assoc(p, :site),
        join: d in assoc(s, :domains),
        where: d.name == ^host and (p.path == ^path or p.path == ^suffixed_path),
        preload: [site: [pages: []]]
      )
    )
  end

  defp add_html_suffix("/") do
    "/index.html"
  end

  defp add_html_suffix(path) do
    path <> ".html"
  end
end
