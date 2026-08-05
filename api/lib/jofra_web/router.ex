defmodule JofraWeb.Router do
  use JofraWeb, :router

  import JofraWeb.UserAuth

  pipeline :api do
    plug :accepts, ["json"]
  end

   scope "/api", JofraWeb do
     pipe_through :api
   end

  ## Authentication routes

end
