defmodule AffableWeb.DashboardController do
  use AffableWeb, :controller

  def show(%{assigns: %{current_user: user}} = conn, _params) do
    render(conn, "show.html", user: user |> Affable.Repo.preload(sites: :domains))
  end
end
