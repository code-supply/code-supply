# TODO rename to HomeHTML when fully migrated. See note in affable_web.ex
defmodule AffableWeb.HomeView do
  use AffableWeb, :html

  embed_templates("home_html/*")
end
