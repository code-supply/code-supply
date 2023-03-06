defmodule Affable.URIRewriter do
  def rewrite(%URI{path: nil} = uri), do: uri

  def rewrite(
        %URI{
          scheme: nil,
          userinfo: nil,
          host: nil,
          port: nil,
          path: path
        } = uri
      ),
      do: %{
        uri
        | path:
            path
            |> String.replace("index.html", "/")
            |> String.replace(~r|^(.+).html$|, "/\\1")
      }

  def rewrite(uri), do: uri
end
