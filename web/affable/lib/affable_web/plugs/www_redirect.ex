defmodule AffableWeb.Plugs.WwwRedirect do
  alias Affable.Domains

  def init(_) do
  end

  def call(%Plug.Conn{host: "affable.app"} = conn, _) do
    conn
    |> Plug.Conn.put_status(:moved_permanently)
    |> Phoenix.Controller.redirect(
      external: Plug.Conn.request_url(conn) |> String.replace("affable.app", "www.affable.app")
    )
  end

  def call(%Plug.Conn{host: host} = conn, _) do
    domain = Domains.by_name(host)

    case domain do
      nil ->
        conn

      %{name: ^host} ->
        conn

      _ ->
        conn
        |> Plug.Conn.put_status(:moved_permanently)
        |> Phoenix.Controller.redirect(
          external: Plug.Conn.request_url(conn) |> String.replace(host, domain.name)
        )
        |> Plug.Conn.halt()
    end
  end
end
