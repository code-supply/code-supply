defmodule AffableWeb.Api.SitesController do
  use AffableWeb, :controller

  alias Affable.Sites
  alias Affable.ID

  import Affable.Sites.Raw, only: [raw: 1]

  def show(conn, %{"id" => site_name}) do
    site_id = ID.id_from_site_name(site_name)
    {:ok, site} = Sites.set_available(site_id, DateTime.utc_now())

    Phoenix.PubSub.broadcast!(:affable, site.internal_name, site)

    json(conn, site.latest_publication.data)
  end

  def preview(conn, %{"id" => site_name}) do
    json(
      conn,
      site_name
      |> ID.id_from_site_name()
      |> Sites.get_site!()
      |> raw()
    )
  end
end
