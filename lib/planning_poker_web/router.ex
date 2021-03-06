defmodule PlanningPokerWeb.Router do
  use PlanningPokerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PlanningPokerWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :cookies_to_session
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :protected do
   plug :basic_auth
  end

  defp basic_auth(conn, _opts) do
    username = System.fetch_env!("AUTH_USERNAME")
    password = System.fetch_env!("AUTH_PASSWORD")
    Plug.BasicAuth.basic_auth(conn, username: username, password: password)
  end

  defp cookies_to_session(conn, _opts) do
    user_name = Map.get(conn.cookies, "user_name")
    conn |> put_session(:user_name, user_name)
  end

  scope "/", PlanningPokerWeb do
    pipe_through :browser

    live "/", PageLive, :index
    live "/room/:id", RoomLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", PlanningPokerWeb do
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
      pipe_through :browser
      live_dashboard "/dashboard", metrics: PlanningPokerWeb.Telemetry
    end
  end

  if Mix.env() in [:prod] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:browser, :protected]
      live_dashboard "/dashboard", metrics: PlanningPokerWeb.Telemetry
    end
  end

  scope "/", PlanningPokerWeb do
    pipe_through :browser
    get "/*other", RedirectController, :redirect_home
  end
end
