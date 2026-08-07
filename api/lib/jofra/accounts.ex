defmodule Jofra.Accounts do
  import Ecto.Query
  alias Jofra.Repo

  def get_user_by_did(did) do
    Jofra.Accounts.User
    |> preload(:players)
    |> where([u], u.did == ^did)
    |> Repo.one()
  end
end
