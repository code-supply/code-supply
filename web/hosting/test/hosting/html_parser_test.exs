defmodule Hosting.HTMLParserTest do
  use Hosting.DataCase, async: true

  alias Hosting.HTMLParser

  test "returns a parsed doc" do
    assert [{"html", [], [{"body", [], [_|_]}]}] =
             HTMLParser.parse("""
             <!doctype html>
             <html>
             <body>
               <section id="content">
                 <p class="headline">Floki</p>
                 <span class="headline">Enables search using CSS selectors</span>
                 <a href="https://github.com/philss/floki">Github page</a>
                 <span data-model="user">philss</span>
               </section>
               <a href="https://hex.pm/packages/floki">Hex package</a>
             </body>
             </html>
             """)
  end

  test "removes JS bits" do
    assert [{"html", [], [{"head", [], []}, {"body", [], []}]}] =
             HTMLParser.parse("""
             <!doctype html>
             <html>
               <head>
               <script>alert('hi')</script>
               </head>
             <body>
               <script>stuff</script>
             </body>
             </html>
             """)
  end
end
