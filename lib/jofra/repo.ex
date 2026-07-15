defmodule Jofra.Repo do
  use Ecto.Repo,
    otp_app: :jofra,
    adapter: Ecto.Adapters.Postgres
end
