defmodule JofraWeb.Router do
  use JofraWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Corsica,
      origins: ["http://127.0.0.1:3000"],
      allow_credentials: true
    plug Plug.Session, Jofra.OAuthSessionConfig.opts()
    plug :fetch_session
    plug Jofra.Plugs.BlueskySession
  end

  scope "/api", JofraWeb do
    pipe_through :api

    scope "/me" do
      get "/", MeController, :me
    end
  end

  forward "/oauth", Jofra.OAuthRouter
end
