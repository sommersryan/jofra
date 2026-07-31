defmodule Jofra.Jobs.FollowerSync do
  alias Jofra.Infra.BlueskyClient

  def sync() do
    with { :ok, token } <- BlueskyClient.authenticate(),
         { :ok, followers } <- BlueskyClient.followers("skyball.live", token, nil) do

      now = DateTime.utc_now() |> DateTime.truncate(:second)

      entries = followers
        |> Enum.map(fn f -> %{
          id: Ecto.UUID.generate(),
          did: f["did"],
          handle: f["handle"],
          avatar: f["avatar"],
          display_name: f["displayName"],
          inserted_at: now,
          updated_at: now
        } end)

      Jofra.Repo.insert_all(
        Jofra.Accounts.User,
        entries,
        on_conflict: {:replace, [:handle, :updated_at]},
        conflict_target: :did
      )
    else
      resp -> resp
    end
  end
end