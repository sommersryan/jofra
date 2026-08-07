defmodule JofraWeb.MeJSON do
  def show(user) do
    %{
      data: data(user)
    }
  end

  defp data(%{ current_user: user }) when is_nil(user) do
    nil
  end

  defp data(%{ current_user:  user }) do
    %{
      did: user.did,
      handle: user.handle,
      avatar: user.avatar,
      display_name: user.display_name,
      players: user.players
    }
  end
end