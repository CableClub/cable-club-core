defmodule BGBLink do
  use GenServer
  @cmd_version 1
  @version_maj 1
  @version_min 4
  @cmd_joypad 101
  @cmd_sync1 104
  @cmd_sync2 105
  @cmd_sync3 106
  @cmd_status 108

  def start_link(port \\ 8765) do
    GenServer.start_link(__MODULE__, port)
  end

  def write(pid, packet) do
    GenServer.cast(pid, {:write, packet})
  end

  def _write(state, packet) do
    # IO.inspect(packet, label: "send", base: :hex)
    :gen_tcp.send(state.socket, packet)
  end

  def init(port) do
    {:ok, socket} =
      :gen_tcp.connect('localhost', port, [:binary, {:active, true}, {:nodelay, true}])

    {:ok, cone_link} = ConeLink.start_link(self())

    send(self(), :handshake)
    {:ok, %{socket: socket, timestamp: 0, cone_link: cone_link}}
  end

  def handle_info(:handshake, state) do
    _write(state, <<@cmd_version, @version_maj, @version_min, 0, 0::32>>)
    _write(state, <<@cmd_status, 0x05, 0, 0, 0::32>>)
    {:noreply, state}
  end

  # handshake
  def handle_info({:tcp, socket, packet}, %{socket: socket} = state) do
    # IO.inspect(packet, label: "recv", base: :hex)
    _handle_packet(packet, state)
  end

  def handle_info({:handle_packet, packet}, state) do
    :gen_tcp.send(state.socket, packet)
    {:noreply, state}
  end

  def _handle_packet(<<packet::binary-8, rest::binary>>, state) do
    ConeLink.handle_packet(state.cone_link, packet)
    _handle_packet(rest, state)
  end

  def _handle_packet(<<>>, state) do
    {:noreply, state}
  end
end
