defmodule Jofra.Model.Side do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sides" do
    field :name, :string
    field :location, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(side, attrs) do
    side
    |> cast(attrs, [:name, :location])
    |> validate_required([:name, :location])
  end
end
