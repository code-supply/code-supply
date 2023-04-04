# TODO rename to HomeHTML when fully migrated. See note in hosting_web.ex
defmodule HostingWeb.HomeView do
  use HostingWeb, :html

  embed_templates("home_html/*")
end
