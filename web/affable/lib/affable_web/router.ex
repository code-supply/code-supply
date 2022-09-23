defmodule AffableWeb.Router do
  use AffableWeb, :router

  import AffableWeb.UserAuth

  control_plane_host = Application.fetch_env!(:affable, AffableWeb.Endpoint)[:url][:host]
  control_plane = [host: control_plane_host, alias: AffableWeb]

  pipeline :site_browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {AffableWeb.LayoutView, :site_root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :stylesheet do
    plug(:accepts, ["css"])
  end

  pipeline :www_redirect do
    plug AffableWeb.Plugs.WwwRedirect
  end

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {AffableWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
  end

  scope control_plane ++ [path: "/"] do
    pipe_through(:browser)

    get("/", HomeController, :show)
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)
      live_dashboard("/dashboard", metrics: AffableWeb.Telemetry)
    end
  end

  if Mix.env() == :dev do
    forward("/sent_emails", Bamboo.SentEmailViewerPlug)
  end

  ## Authentication routes

  scope control_plane ++ [path: "/"] do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    get("/users/register", UserRegistrationController, :new)
    post("/users/register", UserRegistrationController, :create)
    get("/users/log_in", UserSessionController, :new)
    post("/users/log_in", UserSessionController, :create)
    get("/users/reset_password", UserResetPasswordController, :new)
    post("/users/reset_password", UserResetPasswordController, :create)
    get("/users/reset_password/:token", UserResetPasswordController, :edit)
    put("/users/reset_password/:token", UserResetPasswordController, :update)
  end

  scope control_plane ++ [path: "/"] do
    pipe_through([:browser, :require_authenticated_user])

    live("/sites", SitesLive, :index)
    live("/sites/:id/edit", EditorLive, :edit)

    live("/sites/:id/pages/:page_id/edit", EditorLive, :edit)
    live("/assets", AssetsLive, :index)
    live("/domains", DomainsLive, :index)
    get("/users/settings", UserSettingsController, :edit)
    put("/users/settings/update_password", UserSettingsController, :update_password)
    put("/users/settings/update_email", UserSettingsController, :update_email)
    get("/users/settings/confirm_email/:token", UserSettingsController, :confirm_email)
    delete("/users/settings/delete_account", UserSettingsController, :delete_account)
  end

  scope control_plane ++ [path: "/"] do
    pipe_through([:browser])

    delete("/users/log_out", UserSessionController, :delete)
    get("/users/confirm", UserConfirmationController, :new)
    post("/users/confirm", UserConfirmationController, :create)
    get("/users/confirm/:token", UserConfirmationController, :confirm)
  end

  scope path: "/stylesheets", alias: AffableWeb do
    pipe_through([:stylesheet, :www_redirect])
    get("/*path", StylesheetController, :show)
  end

  scope path: "/", alias: AffableWeb do
    pipe_through([:site_browser, :www_redirect])
    get("/*path", PageController, :show)
  end
end
