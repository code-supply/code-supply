defmodule HostingWeb.Router do
  use HostingWeb, :router

  import HostingWeb.UserAuth

  control_plane_host = Application.fetch_env!(:hosting, HostingWeb.Endpoint)[:url][:host]
  control_plane = [host: control_plane_host, alias: HostingWeb]

  pipeline :site_browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {HostingWeb.LayoutView, :site_root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :stylesheet do
    plug(:accepts, ["css"])
  end

  pipeline :www_redirect do
    plug HostingWeb.Plugs.WwwRedirect
  end

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {HostingWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
  end

  scope control_plane ++ [path: "/"] do
    pipe_through(:browser)

    get("/", HomeController, :show)
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:hosting, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: HostingWeb.Telemetry)
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  # not currently scoped to control_plane as test helpers like follow_redirect won't work with hosts
  scope path: "/" do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{HostingWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", HostingWeb.UserRegistrationLive, :new
      live "/users/log_in", HostingWeb.UserLoginLive, :new
      live "/users/reset_password", HostingWeb.UserForgotPasswordLive, :new
      live "/users/reset_password/:token", HostingWeb.UserResetPasswordLive, :edit
    end

    post "/users/log_in", HostingWeb.UserSessionController, :create
  end

  scope control_plane ++ [path: "/"] do
    pipe_through([:browser, :require_authenticated_user])

    live_session :require_authenticated_user,
      on_mount: [{HostingWeb.UserAuth, :ensure_authenticated}] do
      live("/sites", SitesLive, :index)
      live("/sites/:id/edit", EditorLive, :edit)
      live("/sites/:site_id/uploader", UploaderLive, :new)
      live("/assets", AssetsLive, :index)
      live("/domains", DomainsLive, :index)

      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope control_plane ++ [path: "/"] do
    pipe_through([:browser])

    delete("/users/log_out", UserSessionController, :delete)

    live_session :current_user,
      on_mount: [{HostingWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  scope path: "/stylesheets", alias: HostingWeb do
    pipe_through([:stylesheet, :www_redirect])
    get("/*path", StylesheetController, :show)
  end

  scope path: "/", alias: HostingWeb do
    pipe_through([:site_browser, :www_redirect])
    get("/*path", PageController, :show)
  end
end