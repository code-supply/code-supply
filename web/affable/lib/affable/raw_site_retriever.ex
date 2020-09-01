defmodule Affable.RawSiteRetriever do
  @type id :: integer()
  @callback get_raw_site(id) :: {:ok, map()} | {:error, :not_found}
end
