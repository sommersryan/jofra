defmodule Jofra.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :did, :string
    field :handle, :string
    field :avatar, :string
    field :display_name, :string
    field :confirmed_at, :utc_datetime

    has_many :players, Jofra.Model.Player

    timestamps(type: :utc_datetime)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:did, :handle])
    |> validate_required([:did, :handle])
    |> unique_constraint(:did)
  end
end
