defmodule CableClubWeb.Router do
  use CableClubWeb, :router

  import CableClubWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CableClubWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CableClubWeb do
    pipe_through :browser

    live "/", PageLive, :index
    get "/docs/pokemon/gen1/link", DocsController, :pokemon_gen1_link
  end

  # Other scopes may use custom stacks.
  # scope "/api", CableClubWeb do
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
      live_dashboard "/dashboard", metrics: CableClubWeb.Telemetry
    end
  end

  ## Authentication routes

  scope "/", CableClubWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]
  end

  scope "/", CableClubWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update

    live "/play", Pokemon.Gen1.TradeCenterLive, :index
    live "/play/new", Pokemon.Gen1.TradeCenterLive, :new
    live "/play/join", Pokemon.Gen1.TradeCenterLive, :join
  end

  scope "/", CableClubWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/oauth/discord", OAuth.DiscordController, :oauth
    get "/oauth/discord/tos", OAuth.DiscordController, :tos
  end
end
