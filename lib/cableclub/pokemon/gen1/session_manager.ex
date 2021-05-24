defmodule CableClub.Pokemon.Gen1.SessionManager do
  alias CableClub.Pokemon.Gen1.Session

  def new(_socket) do
  end

  def join(_socket) do
  end

  def player_join(_code) do
    Session.player_join(Session)
  end

  def exchange_byte(session, data) do
    Session.exchange_byte(session, data)
  end
end
