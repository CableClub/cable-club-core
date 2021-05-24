defmodule ConeLink2 do
  use GenServer
  alias Circuits.UART

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def init(_) do
    {:ok, player1} = UART.start_link()
    {:ok, player2} = UART.start_link()

    :ok = UART.open(player1, "/dev/ttyUSB0", speed: 115_200, active: true, id: :pid)
    :ok = UART.open(player2, "/dev/ttyUSB1", speed: 115_200, active: true, id: :pid)

    {:ok, %{player1: player1, player2: player2}}
  end

  def handle_info({:circuits_uart, player1, <<data>>}, %{player1: player1} = state) do
    UART.write(state.player2, <<data>>)
    {:noreply, state}
  end

  def handle_info({:circuits_uart, player2, <<data>>}, %{player2: player2} = state) do
    UART.write(state.player1, <<data>>)
    {:noreply, state}
  end
end
