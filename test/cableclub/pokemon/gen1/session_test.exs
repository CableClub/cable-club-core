defmodule CableClub.Pokemon.Gen1.SessionTest do
  use ExUnit.Case
  alias CableClub.Pokemon.Gen1.Session

  setup %{test: test} do
    registry = :ets.new(test, [:public, :set])
    {:ok, session} = Session.start_link(registry)
    %{session: session, registry: registry}
  end

  test "code", %{session: session, registry: registry} do
    code = Session.code(session)
    assert [{^code, ^session}] = :ets.lookup(registry, code)
  end
end
