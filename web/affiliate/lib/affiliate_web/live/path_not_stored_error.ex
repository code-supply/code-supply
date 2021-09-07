defmodule AffiliateWeb.PathNotStoredError do
  defexception [:message, plug_status: 404]
end
