defmodule CableClubWeb.Pokemon.Gen1.TradeController do
  use CableClubWeb, :controller
  alias CableClub.Pokemon.Gen1.{Trade, Trainer, Pokemon}

  def show(conn, %{"id" => _id}) do
    trade = %Trade{
      player1: %Trainer{nickname: "redcone", trainer_id: 0x696969},
      player2: %Trainer{nickname: "bluecone", trainer_id: 0x420420},
      player1_pokemon: %Pokemon{
        type1: :Ground,
        level1: 0,
        current_hp: 155,
        species: :Sandslash,
        move4_pp: 76,
        move4: :Dig,
        move1_pp: 20,
        defense_ev: 10784,
        special: 77,
        move3_pp: 20,
        status: :"No Effect",
        max_hp: 155,
        attack: 122,
        move2_pp: 30,
        special_ev: 9175,
        catch_rate: 255,
        experience: 112_031,
        move3: :Slash,
        iv: 40793,
        move1: :Swift,
        type2: :Ground,
        speed_ev: 9852,
        move2: :Cut,
        attack_ev: 10858,
        defense: 137,
        original_trainer_id: 0x696969,
        level2: 48,
        speed: 84
      },
      player2_pokemon: %Pokemon{
        type1: :Ground,
        level1: 0,
        current_hp: 155,
        species: :Sandslash,
        move4_pp: 76,
        move4: :Dig,
        move1_pp: 20,
        defense_ev: 10784,
        special: 77,
        move3_pp: 20,
        status: :"No Effect",
        max_hp: 155,
        attack: 122,
        move2_pp: 30,
        special_ev: 9175,
        catch_rate: 255,
        experience: 112_031,
        move3: :Slash,
        iv: 40793,
        move1: :Swift,
        type2: :Ground,
        speed_ev: 9852,
        move2: :Cut,
        attack_ev: 10858,
        defense: 137,
        original_trainer_id: 0x420420,
        level2: 48,
        speed: 84
      }
    }

    render(conn, "show.html", trade: trade)
  end
end
