defmodule CableClub.Pokemon.Gen1.Trainer do
  use Ecto.Schema
  import Ecto.Changeset, warn: false

  schema "pokemon_gen1_trainers" do
    belongs_to :user, CableClub.Accounts.User
    field :name, :binary, null: false
    field :trainer_id, :binary, null: false
  end
end
