defmodule HostingWeb.Origin do
  alias Hosting.Domains

  @control_plane_host Application.compile_env!(:hosting, :host)

  def check_origin(%URI{host: host}) do
    host in [@control_plane_host] or
      Domains.by_name(host) != nil
  end
end
