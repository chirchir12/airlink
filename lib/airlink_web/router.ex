defmodule AirlinkWeb.Router do
  use AirlinkWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :is_system do
    plug AirlinkWeb.IsSystemPlug
  end

  pipeline :captive_user do
    plug AirlinkWeb.IsCaptivePlug
  end

  pipeline :ensure_authenticated do
    plug AirlinkWeb.EnsureAuthenticatedPlug
  end

  # captive endpoints
  # captive endpoints: No Auth
  scope "/v1/api/captive", AirlinkWeb do
    pipe_through [:api, :captive_user]
    post "/create", CaptiveController, :create
    # test post to router
    post "/test", CaptiveController, :test_post_to_router
  end

  # captive endpoints: Auth-cookie
  scope "/v1/api/captive", AirlinkWeb do
    pipe_through [:api, :captive_user, :ensure_authenticated]

    # list packages
    get "/plans/list/:company_id", PlanController, :index
    # get plans
    get "/plans/:uuid", PlanController, :show
    # create payment
    post "/payments", PaymentController, :create
    # get payment
    get "/payments/:ref_id", PaymentController, :show

    # get customer
    get "/customer", AuthController, :show

    # get customer
    get "/company", CompanyController, :show
  end

  # system to system endpoints
  scope "/v1/api/system", AirlinkWeb do
    pipe_through [:api, :is_system, :ensure_authenticated]
  end

  # portal endpoints
  scope "/v1/api", AirlinkWeb do
    pipe_through [:api, :ensure_authenticated]

    post "/hotspots", HotspotController, :create
    get "/hotspots/list/:company_id", HotspotController, :index
    get "/hotspots/:id", HotspotController, :show
    put "/hotspots/:id", HotspotController, :update

    # plans
    post "/plans", PlanController, :create
    get "/plans/list/:company_id", PlanController, :index
    get "/plans/:id", PlanController, :show
    put "/plans/:id", PlanController, :update
    delete "/plans/:id", PlanController, :delete
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
