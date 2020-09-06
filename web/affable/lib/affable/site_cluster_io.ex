defmodule Affable.SiteClusterIO do
  alias Affable.Sites.Site

  @type id :: integer()
  @callback get_raw_site(id) :: {:ok, map()} | {:error, :not_found}
  @callback set_available(id, %DateTime{}) :: {:ok, %Site{}}
end
