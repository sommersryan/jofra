defmodule Jofra.Repo.Migrations.CreatePlayerRatings do
  use Ecto.Migration

  def change do
    create table(:player_ratings, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :effective_date, :utc_datetime
      add :expiration_date, :utc_datetime
      add :ratings, :map
      add :player_id, references(:players, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:player_ratings, [:player_id])
  end
end
