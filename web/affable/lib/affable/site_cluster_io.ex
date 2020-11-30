defmodule Affable.SiteClusterIO do
  alias Affable.Sites.Site

  @type id :: integer()
  @callback get_site!(id) :: %Site{}
  @callback set_available(id, %DateTime{}) :: {:ok, %Site{}}
end
