defmodule CableClubWeb.USBV1Channel do
  use CableClubWeb, :channel
  alias CableClub.Accounts
  alias CableClub.Pokemon.Gen1.SessionManager

  def join(_topic, %{"session_code" => session_code, "session_token" => session_token}, socket) do
    with {:ok, token} <- Base.url_decode64(session_token),
         {:ok, user} <- check_token(token),
         {:ok, session} <- check_code(session_code) do
      {:ok,
       socket
       |> assign(:user, user)
       |> assign(:session_code, session_code)
       |> assign(:session, session)}
    end
  end

  def handle_in("exchange_byte", %{"data" => data}, socket) do
    SessionManager.exchange_byte(socket.assigns.session, data)
    {:noreply, socket}
  end

  def handle_info({:exchange_byte, data}, socket) do
    push(socket, "exchange_byte", %{data: data})
    {:noreply, socket}
  end

  def check_token(token) do
    case Accounts.get_user_by_session_token(token) do
      nil -> {:error, %{reason: "unauthorized"}}
      user -> {:ok, user}
    end
  end

  def check_code(session_code) do
    SessionManager.player_join(session_code)
  end
end
