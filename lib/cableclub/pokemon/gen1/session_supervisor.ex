defmodule CableClub.Pokemon.Gen1.SessionSupervisor do
  use DynamicSupervisor

  @doc false
  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @doc "start a new session"
  def start_child() do
    DynamicSupervisor.start_child(
      __MODULE__,
      {CableClub.Pokemon.Gen1.Session, [:pokemon_gen1_session_registry]}
    )
  end

  @doc "lookup session by it's code"
  def find_child(code) do
    case :ets.lookup(:pokemon_gen1_session_registry, code) do
      [{^code, session}] -> {:ok, session}
      [] -> {:error, "could not find session"}
    end
  end

  @impl DynamicSupervisor
  def init(_arg) do
    _ = :ets.new(:pokemon_gen1_session_registry, [:public, :named_table])
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
