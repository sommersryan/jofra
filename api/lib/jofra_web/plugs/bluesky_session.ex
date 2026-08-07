defmodule Jofra.Plugs.BlueskySession do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    with key when not is_nil(key) <- Atex.OAuth.current_session_key(conn),
    { :ok, session } <- Atex.OAuth.SessionStore.get(key),
    user when not is_nil(user) <- Jofra.Accounts.get_user_by_did(session.sub) do
      assign(conn, :current_user, user)
    else
      error ->
        assign(conn, :current_user, nil)
    end
  end
end