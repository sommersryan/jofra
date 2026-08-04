defmodule Jofra.Model.PlayerRating do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "player_ratings" do
    field :effective_date, :utc_datetime
    field :expiration_date, :utc_datetime
    field :ratings, :map

    belongs_to :player, Jofra.Model.Player

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(player_rating, attrs) do
    player_rating
    |> cast(attrs, [:effective_date, :expiration_date, :ratings])
    |> validate_required([:effective_date, :expiration_date])
  end
end
