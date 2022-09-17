defmodule AffableWeb.Origin do
  alias Affable.Domains

  @control_plane_host Application.fetch_env!(:affable, AffableWeb.Endpoint)[:url][:host]

  def check_origin(%URI{host: host}) do
    host in [@control_plane_host] or
      Domains.by_name(host) != nil
  end
end
