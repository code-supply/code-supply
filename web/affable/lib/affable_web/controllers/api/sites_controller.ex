defmodule AffableWeb.Api.SitesController do
  use AffableWeb, :controller

  alias Affable.Sites

  import Affable.Sites.Raw, only: [raw: 1]

  def show(conn, %{"id" => site_id}) do
    site = Sites.get_site!(site_id)
    json(conn, site.latest_publication.data)
  end

  def preview(conn, %{"id" => site_id}) do
    site = Sites.get_site!(site_id)
    json(conn, raw(site))
  end
end
