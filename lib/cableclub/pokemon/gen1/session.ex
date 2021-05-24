defmodule CableClub.Pokemon.Gen1.Session do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def player_join(session) do
    GenServer.call(session, :player_join)
  end

  def exchange_byte(session, data) do
    GenServer.call(session, {:exchange_byte, data})
  end

  def init(_) do
    {:ok, %{player1: nil, player2: nil}}
  end

  def handle_call(:player_join, {pid, _tag}, %{player1: nil} = state) do
    {:reply, {:ok, self()}, %{state | player1: pid}}
  end

  def handle_call(:player_join, {pid, _tag}, %{player2: nil} = state) do
    {:reply, {:ok, self()}, %{state | player2: pid}}
  end

  def handle_call({:exchange_byte, data}, {player1, _}, %{player1: player1} = state) do
    send(state.player2, {:exchange_byte, data})
    {:reply, :ok, state}
  end

  def handle_call({:exchange_byte, data}, {player2, _}, %{player2: player2} = state) do
    send(state.player1, {:exchange_byte, data})
    {:reply, :ok, state}
  end
end
