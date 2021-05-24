defmodule CableClubWeb.USBV1Channel do
  use CableClubWeb, :channel
  alias CableClub.Accounts

  def join(_topic, %{"session_code" => session_code, "session_token" => session_token}, socket) do
    with {:ok, token} <- Base.url_decode64(session_token),
         {:ok, user} <- check_token(token, socket) do
      {:ok,
       socket
       |> assign(:user, user)
       |> assign(:session_code, session_code)}
    end
  end

  def check_token(token, _socket) do
    case Accounts.get_user_by_session_token(token) do
      nil -> {:error, %{reason: "unauthorized"}}
      user -> {:ok, user}
    end
  end
end
