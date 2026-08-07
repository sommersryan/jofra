defmodule Jofra.OAuthRouter do
  use Plug.Router
  use Plug.ErrorHandler
  plug Plug.Session, Jofra.OAuthSessionConfig.opts()
  plug :match
  plug :dispatch

  forward "/", to: Atex.OAuth.Plug,
    init_opts: [
      callback: { __MODULE__, :oauth_callback, [] },
      logout_callback: { __MODULE__, :logout_callback, [] }
    ]

  @frontend_url Application.compile_env!(:jofra, :frontend_url)

  def oauth_callback(conn) do
    conn
    |> Plug.Conn.put_resp_header("location", @frontend_url <> "auth/complete")
    |> Plug.Conn.send_resp(302, "")
  end

  def logout_callback(conn) do
    conn
    |> Plug.Conn.put_resp_header("location", @frontend_url <> "/")
  end

  @impl Plug.ErrorHandler
    def handle_errors(conn, %{reason: %Atex.OAuth.Error{} = error, kind: :error, stack: _}) do
      conn
      |> Plug.Conn.put_resp_header("location", @frontend_url <> "/login?error=#{error.reason}")
      |> Plug.Conn.send_resp(302, "")
    end

  def handle_errors(conn, _), do:
    Plug.Conn.send_resp(conn, conn.status || 500, "")
end
