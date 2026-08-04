defmodule Jofra.Users do
  import Ecto.Query

  def users_without_players() do
    Jofra.Accounts.User
    |> join(:left, [u], p in assoc(u, :players))
    |> where([u, p], is_nil(p.id))
    |> Jofra.Repo.all()
  end
end