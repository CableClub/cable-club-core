defmodule CableClub.Pokemon.Gen1.Trade do
  use Ecto.Schema

  schema "pokemon_gen1_trades" do
    field :player1_trainer_id, :id
    field :player1, :map, virtual: true

    field :player2_trainer_id, :id
    field :player2, :map, virtual: true

    field :player1_pokemon_id, :id
    field :player1_pokemon, :map, virtual: true

    field :player2_pokemon_id, :id
    field :player2_pokemon, :map, virtual: true

    timestamps()
  end
end
