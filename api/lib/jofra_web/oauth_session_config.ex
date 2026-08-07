defmodule Jofra.OAuthSessionConfig do
  def opts do
    [
      store: :cookie,
      key: "_jofra_oauth",
      signing_salt: "jofra-oauth-session",
      same_site: "Lax",
      secure: Application.get_env(:jofra, :env) == :prod
    ]
  end
end