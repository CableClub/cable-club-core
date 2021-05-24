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
    handle_bgb(packet, state)
    :ok = UART.write(state.uart, packet)
    {:noreply, state}
  end

  def handle_info({:circuits_uart, _tty, data}, state) do
    handle_uart(data, state)
    {:noreply, state}
  end

  def handle_bgb(<<104, _::binary>> = packet, state) do
    IO.puts("sync1 data from bgb")
    :binpp.pprint(packet)
    state
  end

  def handle_bgb(<<105, _::binary>> = packet, state) do
    IO.puts("sync2 data from bgb")
    :binpp.pprint(packet)
    state
  end

  def handle_bgb(_, state) do
    state
  end

  def handle_uart(<<>>, state) do
    state
  end

  def handle_uart(<<packet::binary-8, rest::binary>>, state) do
    do_handle_uart(packet, state)
    handle_uart(rest, state)
  end

  def handle_uart(packet, state) do
    IO.puts(packet)
    state
  end

  def do_handle_uart(packet, state) do
    log_uart(packet)
    # :binpp.pprint(packet)

    send(state.parent, {:handle_packet, packet})
    state
  end

  def log_uart(<<104, _::binary>> = packet) do
    IO.puts("sync1 from duino:")
    :binpp.pprint(packet)
  end

  def log_uart(<<105, _::binary>> = packet) do
    IO.puts("sync2 from duino:")
    :binpp.pprint(packet)
  end

  def log_uart(_), do: :ok
end
