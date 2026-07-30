defmodule Jofra.Infra.BlueskyClient do
  @bsky_pds "https://bsky.social"

  def authenticate(handle \\ nil, app_password \\ nil) do
    config = Application.fetch_env!(:jofra, :bsky_self)
    handle = handle || config[:handle]
    app_password = app_password || config[:app_password]

    case Req.post(@bsky_pds <> "/xrpc/com.atproto.server.createSession",
      json: %{ identifier: handle, password: app_password }) do
        {:ok, %{ status: 200, body: %{ "accessJwt" => token }}} ->
          { :ok, token }

        {:ok, %{ body: body }} ->
          { :error, { :auth_failed, body }}

        {:error, reason } ->
          { :error, reason }
      end
  end

  def followers(handle, token, cursor, followers \\ []) do
    response = Req.get(@bsky_pds <> "/xrpc/app.bsky.graph.getFollowers",
        params: %{ actor: handle, limit: 100 }
          |> then(fn p -> if cursor, do: Map.put(p, :cursor, cursor), else: p end),
        headers: [{"authorization", "Bearer #{token}"}]
    )

    case response do
      {:ok, %{status: 200, body: %{"followers" => new_followers} = body}} ->
        next_cursor = Map.get(body, "cursor")

        if next_cursor && next_cursor != "" do
          followers(handle, token, next_cursor, followers ++ new_followers)
        else
          { :ok, followers ++ new_followers }
        end

        {:ok, %{body: body}} ->
          {:error, {:xrpc_error, body}}

        {:error, reason} ->
          {:error, reason}
    end
  end
end