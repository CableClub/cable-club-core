defmodule CableClub.Pokemon.Gen1.SessionManager do
  @moduledoc """
  Entrypoint for communication between two connections
  """
  alias CableClub.Pokemon.Gen1.{SessionSupervisor, Session}

  @doc """
  Creates a new session. caller will not automatically join
  """
  def new(ref) do
    with {:ok, session} <- SessionSupervisor.start_child(),
         :ok <- Session.join(session, ref) do
      {:ok, session}
    end
  end

  @doc """
  Lookup and join a session by it's code
  """
  def join(ref, code) do
    with {:ok, session} <- SessionSupervisor.find_child(code),
         :ok <- Session.join(session, ref) do
      {:ok, session}
    end
  end

  @doc "Returns the unique code for the session"
  defdelegate code(sesssion), to: Session

  @doc "Signal a session start. both connections must call this function with the same type"
  defdelegate start(session, type), to: Session

  @doc "Stop a session"
  defdelegate stop(session), to: Session

  @doc "Transfer a single byte"
  defdelegate transfer(session, byte), to: Session
end
