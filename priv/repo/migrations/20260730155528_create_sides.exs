defmodule Jofra.Repo.Migrations.CreateSides do
  use Ecto.Migration

  def change do
    create table(:sides, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :location, :string

      timestamps(type: :utc_datetime)
    end
  end
end
