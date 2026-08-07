defmodule JofraWeb.MeController do
  use JofraWeb, :controller
  
  def me(conn, _) do
    render(conn, :show)
  end
end