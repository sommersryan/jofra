defmodule Jofra.Model.Player do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "players" do
    field :identifier, :string
    field :display_name, :string
    field :is_human, :boolean, default: false
    field :ext, :map

    has_many :player_ratings, Jofra.Model.PlayerRating
    belongs_to :user, Jofra.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:display_name, :identifier, :is_human, :ext])
    |> validate_required([:display_name, :identifier, :is_human])
  end
end
