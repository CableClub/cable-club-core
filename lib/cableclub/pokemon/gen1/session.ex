defmodule CableClub.Pokemon.Gen1.Session do
  @moduledoc """
  Handles brokering two connections
  """
  use GenServer

  @doc false
  def start_link(registry) do
    GenServer.start_link(__MODULE__, registry)
  end

  def join(session, _ref) do
    GenServer.call(session, :join)
  end

  def code(session) do
    GenServer.call(session, :code)
  end

  def start(session, type) do
    GenServer.call(session, {:start, type})
  end

  def stop(session) do
    GenServer.call(session, :stop)
  end

  def transfer(session, byte) do
    GenServer.call(session, {:transfer, byte})
  end

  @impl GenServer
  def init(registry) do
    code = :crypto.strong_rand_bytes(6) |> Base.encode16()
    true = :ets.insert(registry, {code, self()})

    {:ok,
     %{
       registry: registry,
       player1: nil,
       player2: nil,
       code: code,
       type: nil
     }}
  end

  @impl GenServer
  def terminate(_, state) do
    :ets.delete(state.registry, state.code)
  end

  @impl GenServer
  def handle_call(:join, {pid, _tag}, %{player1: nil} = state) do
    {:reply, {:ok, self()}, %{state | player1: pid}}
  end

  def handle_call(:join, {pid, _tag}, %{player2: nil} = state) do
    send(state.player1, {__MODULE__, "session.status", %{ready: true}})
    send(pid, {__MODULE__, "session.status", %{ready: true}})
    {:reply, {:ok, self()}, %{state | player2: pid}}
  end

  def handle_call(_call, _, %{player1: p1, player2: p2} = state) when is_nil(p1) or is_nil(p2) do
    {:reply, {:error, "session not ready"}, state}
  end

  def handle_call(:code, _from, state) do
    {:reply, state.code, state}
  end

  def handle_call({:start, type}, _from, %{type: nil} = state) do
    {:reply, :ok, %{state | type: type}}
  end

  def handle_call({:start, type}, _from, %{type: type} = state) do
    {:reply, :ok, state}
  end

  def handle_call({:start, _requested_type}, _from, %{type: _selected_type} = state) do
    {:reply, {:error, "session type disagreement"}, state}
  end

  def handle_call(:stop, _, state) do
    send(state.player1, {__MODULE__, "session.status", %{ready: false}})
    send(state.player2, {__MODULE__, "session.status", %{ready: false}})
    {:reply, :ok, %{state | type: nil}}
  end

  def handle_call({:transfer, _data}, _, %{type: nil}) do
    {:reply, {:error, "session not started"}}
  end

  def handle_call({:transfer, data}, {player1, _}, %{player1: player1} = state) do
    send(state.player2, {__MODULE__, :transfer, data})
    {:reply, :ok, state}
  end

  def handle_call({:transfer, data}, {player2, _}, %{player2: player2} = state) do
    send(state.player1, {__MODULE__, :transfer, data})
    {:reply, :ok, state}
  end
end
