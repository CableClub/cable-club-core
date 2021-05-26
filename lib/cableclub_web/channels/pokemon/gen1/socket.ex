defmodule CableClubWeb.Pokemon.Gen1.Socket do
  use Phoenix.Socket

  channel "v1", CableClubWeb.Pokemon.Gen1.Channel
  alias CableClub.Accounts

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    with {:ok, token} <- Base.url_decode64(token),
         {:ok, user} <- check_token(token) do
      {:ok,
       socket
       |> assign(:user, user)}
    end
  end

  @impl true
  def id(socket), do: "pokemon.gen1.socket.#{socket.assigns.user.id}"

  def check_token(token) do
    case Accounts.get_user_by_session_token(token) do
      nil -> {:error, %{reason: "unauthorized"}}
      user -> {:ok, user}
    end
  end
end
