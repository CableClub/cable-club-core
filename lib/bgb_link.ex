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

  defmodule Link do
    defstruct connection: :not_connected,
              trade_center: :init,
              send: 0x1

    def handle_byte(%{connection: :not_connected} = link, 0x2) do
      %{link | send: 0x1, connection: :handshake}
    end

    def handle_byte(%{connection: :handshake} = link, 0x2) do
      %{link | send: 0x0}
    end

    def handle_byte(%{connection: :handshake} = link, 0x60) do
      %{link | send: 0x60, connection: :connected}
    end

    def handle_byte(link, byte) do
      IO.inspect(byte, label: "unhandled_byte for state #{link.connection}", base: :hex)
      link
    end
  end

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

    send(self(), :handshake)
    {:ok, %{socket: socket, timestamp: 0, trade_center: %Link{}}}
  end

  def handle_cast({:write, packet}, state) do
    _write(state, <<@cmd_sync1, 0x1, 0x81, packet, state.timestamp::little-32>>)
    {:noreply, state}
  end

  def handle_info(:handshake, state) do
    _write(state, <<@cmd_version, @version_maj, @version_min, 0, 0::32>>)
    {:noreply, state}
  end

  # handshake
  def handle_info({:tcp, socket, packet}, %{socket: socket} = state) do
    # IO.inspect(packet, label: "recv", base: :hex)
    _handle_packet(packet, state)
  end

  def _handle_packet(<<packet::binary-8, rest::binary>>, state) do
    state = handle_packet(packet, state)
    _handle_packet(rest, state)
  end

  def _handle_packet(<<>>, state) do
    {:noreply, state}
  end

  def handle_packet(<<@cmd_version, @version_maj, @version_min, 0, 0::32>>, state) do
    _write(state, <<@cmd_status, 0x05, 0, 0, 0::32>>)
    _write(state, <<@cmd_sync1, 0x1, 0x81, 0, state.timestamp::little-32>>)
    state
  end

  def handle_packet(<<@cmd_joypad, _::binary>>, state) do
    state
  end

  def handle_packet(<<@cmd_status, _, _, _, _::32>>, state) do
    state
  end

  # def handle_packet(<<@cmd_sync2, 0x2, 0x80, _, 0::32>>, state) do
  #   #   IO.puts("claiming master clock")
  #   #   _write(state, <<@cmd_sync1, 0x0, 0x81, 0, state.timestamp::little-32>>)
  #   state
  # end

  def handle_packet(<<@cmd_sync2, byte, 0x80, _, 0::32>>, state) do
    trade_center = Link.handle_byte(state.trade_center, byte)
    # _write(state, <<@cmd_sync1, trade_center.reply, 0x81, 0, state.timestamp::little-32>>)
    %{state | trade_center: trade_center}
  end

  def handle_packet(
        <<@cmd_sync3, 0, 0, 0, _timestamp::little-32>>,
        %{timestamp: timestamp} = state
      )
      when timestamp < 0xFFFF do
    _write(state, <<@cmd_sync3, 0, 0, 0, state.timestamp::little-32>>)
    %{state | timestamp: state.timestamp + 1}
  end

  def handle_packet(<<@cmd_sync3, 0, 0, 0, _timestamp::little-32>>, %{timestamp: 0xFFFF} = state) do
    _write(state, <<@cmd_sync3, 0, 0, 0, 0::little-32>>)
    %{state | timestamp: 0}
  end

  # ack i think
  def handle_packet(<<@cmd_sync3, 1, _::binary>>, state) do
    IO.puts("here")
    _write(state, <<@cmd_sync1, state.trade_center.out, 0x81, 0, state.timestamp::little-32>>)
    state
  end

  def handle_packet(packet, state) do
    IO.inspect(packet, label: "unhandled packet")
    state
  end
end
