defmodule CableClubWeb.BGBLink.Protocol do
  @moduledoc """
  Handles TCP connections from the BGB Emulator
  """

  alias CableClub.Pokemon.Gen1.Link

  @behaviour :ranch_protocol
  use GenServer

  @cmd_version 1
  @version_maj 1
  @version_min 4

  @cmd_joypad 101
  @cmd_sync1 104
  @cmd_sync2 105
  @cmd_sync3 106
  @sync3_ack 1
  @sync3_sync 0

  @cmd_status 108
  @status_stopped 0x7
  @status_running 0x5

  @doc false
  @impl :ranch_protocol
  def start_link(ref, socket, transport, _proto_opts) do
    pid = :proc_lib.spawn_link(__MODULE__, :proto_init, [ref, socket, transport])
    {:ok, pid}
  end

  @doc false
  def proto_init(ref, socket, transport) do
    :ok = :ranch.accept_ack(ref)
    :ok = transport.setopts(socket, [{:active, true}, {:nodelay, true}])

    :gen_server.enter_loop(__MODULE__, [], %{
      socket: socket,
      transport: transport,
      status: @status_stopped,
      timestamp: 0,
      link: Link.reset(%Link{}),
      in: 0,
      out: 0x1
    })
  end

  @doc false
  @impl GenServer
  def init(_), do: {:stop, :invalid_start}

  @impl GenServer
  def handle_info({:tcp, socket, data}, state = %{socket: socket}) do
    state = enumerate_packet(data, state)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, socket}, state = %{socket: socket, transport: transport}) do
    transport.close(socket)
    IO.puts("closed")
    {:stop, :normal, state}
  end

  def handle_info(:clock, state) do
    state.transport.send(
      state.socket,
      <<@cmd_sync1, state.out, 0x81, 0, state.timestamp::little-32>>
    )

    IO.inspect(state.out, label: "#{state.link.state}", base: :hex)
    {:noreply, state}
  end

  # def inc_timestamp(0xffff), do: 0
  # def inc_timestamp(num), do: num + 1
  def inc_timestamp(_), do: :erlang.system_time(:seconds)

  def enumerate_packet(<<packet::binary-8, rest::binary>>, state) do
    state = handle_packet(packet, state)
    enumerate_packet(rest, state)
  end

  def enumerate_packet(<<>>, state), do: state

  def handle_packet(<<@cmd_version, @version_maj, @version_min, 0, 0::32>> = version, state) do
    state.transport.send(state.socket, version)
    state
  end

  def handle_packet(<<@cmd_joypad, _button, _button_state, 0, 0::32>>, state) do
    state
  end

  def handle_packet(<<@cmd_sync1, data, 0x81, _, _timestamp::little-32>>, state) do
    IO.inspect(data, base: :hex, label: "master mode data")
    state.transport.send(state.socket, <<@cmd_sync3, @sync3_ack, 0, 0, 0::32>>)
    state.transport.send(state.socket, <<@cmd_sync1, 0x1, 0x81, 0, state.timestamp::little-32>>)
    state
  end

  def handle_packet(<<@cmd_sync2, input, 0x80, _, 0::32>>, state) do
    IO.inspect(input, label: "slave mode input", base: :hex)
    {out, link} = Link.transfer(state.link, input)
    %{state | in: input, out: out, link: link}
  end

  def handle_packet(<<@cmd_sync3, @sync3_ack, 0, 0, 0::32>>, state) do
    IO.puts("ack")

    # state.transport.send(state.socket, <<@cmd_sync1, state.out, 0x81, 0, state.timestamp::little-32>>)
    state
  end

  def handle_packet(<<@cmd_sync3, @sync3_sync, 0, 0, timestamp::little-32>>, state) do
    state = %{state | timestamp: timestamp}
    state.transport.send(state.socket, <<@cmd_sync3, @sync3_sync, 0, 0, timestamp::little-32>>)
    state
  end

  def handle_packet(<<@cmd_status, @status_running, 0, 0, 0::32>> = status, state) do
    state.transport.send(state.socket, status)
    :timer.send_interval(100, :clock)
    %{state | status: @status_running}
  end

  def handle_packet(<<@cmd_status, @status_stopped, 0, 0, 0::32>> = _status, state) do
    # state.transport.send(state.socket, status)
    %{state | status: @status_stopped}
  end
end
