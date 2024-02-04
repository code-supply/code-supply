defmodule Hosting.Pages do
  import Ecto.Query, warn: false

  alias Hosting.Repo
  alias Hosting.Sites.{Page, Site}
  alias Hosting.URIRewriter

  @site_stylesheet {"link",
                    [
                      {"rel", "stylesheet"},
                      {"href", "/stylesheets/app.css"}
                    ], []}

  def render(page, %Site{stylesheet: stylesheet}, current_datetime) do
    process(page, stylesheet, current_datetime)
    |> Floki.raw_html()
  end

  defp process(%Page{raw: raw}, "", current_datetime) do
    {:ok, doc} = Floki.parse_document(raw, html_parser: Floki.HTMLParser.Html5ever)

    doc
    |> remove_scripts()
    |> rewrite_links_and_remove_internal_stylesheets()
    |> write_dynamic_data(current_datetime)
  end

  defp process(%Page{} = page, _stylesheet_present, current_datetime) do
    process(page, "", current_datetime)
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

  defp write_dynamic_data(doc, current_datetime) do
    Floki.traverse_and_update(doc, fn
      {el, attrs, children} ->
        if {"data-dynamic", "year"} in attrs do
          {
            el,
            attrs,
            ["#{current_datetime.year}"]
          }
        else
          {
            el,
            attrs,
            children
          }
        end

      other ->
        other
    end)
  end

  defp rewrite_links_and_remove_internal_stylesheets(doc) do
    Floki.traverse_and_update(doc, fn
      {"a", attrs, children} ->
        {
          "a",
          for {"href", url} <- attrs do
            {
              "href",
              url
              |> URI.parse()
              |> URIRewriter.rewrite()
              |> URI.to_string()
            }
          end,
          children
        }

      el ->
        if internal_stylesheet?(el) do
          nil
        else
          el
        end
    end)
  end

  defp remove_scripts(doc) do
    Floki.filter_out(doc, "script")
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

  defp internal_stylesheet?({"link", attrs_tuples, _children}) do
    attrs = Enum.into(attrs_tuples, %{})

    String.downcase(attrs["rel"]) == "stylesheet" and
      !String.starts_with?(attrs["href"], "http")
  end

  defp internal_stylesheet?(_el) do
    false
  end

  defp add_html_suffix(path) do
    if String.ends_with?(path, "/") do
      "#{path}index.html"
    else
      path <> ".html"
    end
  end
end
