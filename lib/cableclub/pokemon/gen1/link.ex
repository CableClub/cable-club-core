defmodule CableClub.Pokemon.Gen1.Link do
  @moduledoc """
  State Machine for a Gen 1 link
  """

  alias CableClub.Pokemon.Gen1.Link

  @type state :: :init | :handshake | :connected | :trade | :battle

  defstruct state: :init,
            sb: 0x1

  @doc "returns a clean state"
  def reset(_link) do
    %Link{}
  end

  @doc "advances the state machine to the next state"
  def step(%Link{state: state} = link) do
    apply(Link, state, [link])
  end

  # function definition for every state

  @doc false
  # def init(%Link{sb: })
end
