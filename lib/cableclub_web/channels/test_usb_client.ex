defmodule CableClubWeb.TestUSBClient do
  @moduledoc """
  Test Websocket Client that connects the prototype UART bridge
  to the USB channel
  """

  use Slipstream, restart: :temporary

  require Logger
  alias Circuits.UART

  @topic "usb:v1"

  def gen_token() do
    user = CableClub.Repo.one(CableClub.Accounts.User)
    token = CableClub.Accounts.generate_user_session_token(user)
    Base.url_encode64(token)
  end

  def start_link(session_token, session_code, tty) do
    Slipstream.start_link(__MODULE__, [session_token, session_code, tty])
  end

  @impl Slipstream
  def init([session_token, session_code, tty]) do
    {:ok, uart} = UART.start_link()
    :ok = UART.open(uart, tty, speed: 115_200, active: true, id: :pid)

    {:ok,
     connect!(uri: "ws://localhost:4000/usb/websocket")
     |> assign(:tty, tty)
     |> assign(:uart, uart)
     |> assign(:session_token, session_token)
     |> assign(:session_code, session_code)}
  end

  @impl Slipstream
  def handle_connect(socket) do
    {:ok,
     join(socket, @topic, %{
       session_code: socket.assigns.session_code,
       session_token: socket.assigns.session_token
     })}
  end

  @impl Slipstream
  def handle_join(@topic, _join_response, socket) do
    # an asynchronous push with no reply:
    # push(socket, @topic, "hello", %{})

    {:ok, socket}
  end

  @impl Slipstream
  def handle_reply(_ref, _data, socket) do
    {:ok, socket}
  end

  @impl Slipstream
  def handle_message(@topic, event, message, socket) do
    Logger.error(
      "Was not expecting a push from the server. Heard: " <>
        inspect({@topic, event, message})
    )

    {:ok, socket}
  end

  @impl Slipstream
  def handle_disconnect(_reason, socket) do
    {:stop, :normal, socket}
  end

  @impl Slipstream
  def handle_info({:circuits_uart, _tty, <<data>>}, socket) do
    {:ok, result} = push!(socket, @topic, "exchange_byte", %{data: data}) |> await_reply()
    :ok = UART.write(socket.assigns.uart, result["data"])
    {:ok, socket}
  end
end
