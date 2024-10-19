defmodule AirlinkWeb.Router do
  use AirlinkWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :is_system do
    plug AirlinkWeb.IsSystemPlug
  end

  pipeline :ensure_authenticated do
    plug AirlinkWeb.EnsureAuthenticatedPlug
  end

  scope "/v1/api/system", AirlinkWeb do
    pipe_through [:api, :is_system, :ensure_authenticated]

  end

  scope "/v1/api", AirlinkWeb do
    pipe_through [:api, :ensure_authenticated]

    resources "/hotspots", HotspotController, except: [:new, :edit]
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:airlink, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: AirlinkWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
