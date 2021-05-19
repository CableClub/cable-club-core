defmodule CableClub.Pokemon.Gen1.Trade do
  use Ecto.Schema

  schema "pokemon_gen1_trades" do
    field :player1_trainer_id, :id
    field :player2_trainer_id, :id
    field :player1_pokemon_id, :id
    field :player2_pokemon_id, :id
    timestamps()
  end
end
