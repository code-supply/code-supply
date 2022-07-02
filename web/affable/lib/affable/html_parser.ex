defmodule Affable.HTMLParser do
  def parse(input) do
    {:ok, doc} = Floki.parse_document(input)

    Floki.find_and_update(doc, "script", fn _ -> :delete end)
  end
end
