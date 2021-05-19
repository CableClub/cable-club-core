defmodule ConeLink do
  use GenServer
  alias Circuits.UART

  def start_link(parent) do
    GenServer.start_link(__MODULE__, parent)
  end

  def handle_packet(link, packet) do
    GenServer.cast(link, {:packet, packet})
  end

  def init(parent) do
    {:ok, uart} = UART.start_link()
    :ok = UART.open(uart, "/dev/ttyUSB0", speed: 115_200, active: true)
    {:ok, %{uart: uart, parent: parent}}
  end

  def handle_cast({:packet, <<packet::binary-8>>}, state) do
    IO.inspect(packet, label: "data from bgb")
    UART.write(state.uart, packet)
    {:noreply, state}
  end

  def handle_info({:circuits_uart, _tty, data}, state) do
    IO.inspect(data, label: "data from duino", base: :hex)
    send(state.parent, {:handle_packet, data})
    {:noreply, state}
  end
end
