defmodule AffiliateWeb.Router do
  use AffiliateWeb, :router

  pipeline :insecure_browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {AffiliateWeb.LayoutView, :root})
    plug(:protect_from_forgery)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", AffiliateWeb do
    pipe_through([:insecure_browser, :put_secure_browser_headers])

    live("/", PageLive, :index)
  end

  scope "/", AffiliateWeb do
    pipe_through(:api)

    put("/", UpdatesController, :update)
  end

  scope "/preview", AffiliateWeb do
    pipe_through(:insecure_browser)

    live("/", PreviewLive, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", AffiliateWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:insecure_browser)
      live_dashboard("/dashboard", metrics: AffiliateWeb.Telemetry)
    end
  end
end
