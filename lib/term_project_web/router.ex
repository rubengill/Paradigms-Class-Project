defmodule TermProjectWeb.Router do
  use TermProjectWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TermProjectWeb.Layouts, :root}
    # plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TermProjectWeb do
    pipe_through :browser

    get "/", PageController, :home

    # live "/lobby", LobbyLive, :index
    # live "/login", LoginLive, :index
    # live "/register", RegisterLive, :index

    get "/lobby", LobbyController, :index
    post "/lobby/create", LobbyController, :create
    post "/lobby/join", LobbyController, :join

    get "/login", SessionController, :new
    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete

    get "/register", RegistrationController, :new
    post "/register", RegistrationController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", TermProjectWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:term_project, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TermProjectWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
