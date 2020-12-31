defmodule AffiliateWeb.UpdatesController do
  use AffiliateWeb, :controller

  alias Affiliate.SiteState

  def update(conn, payload) do
    SiteState.store(payload)
    json(conn, %{})
  end
end
