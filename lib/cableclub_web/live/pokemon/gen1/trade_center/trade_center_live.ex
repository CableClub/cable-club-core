defmodule CableClubWeb.Pokemon.Gen1.TradeCenterLive do
  use CableClubWeb, :live_view

  @impl true
  def mount(_params, %{"current_user" => current_user}, socket) do
    {:ok,
     assign(socket, current_user: current_user)
     |> assign_session_code()}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply,
     socket
     |> assign_session_code()}
  end

  def assign_session_code(%{assigns: %{live_action: :new}} = socket) do
    socket
    |> assign(session_code: Base.encode16(:crypto.strong_rand_bytes(4)))
  end

  def assign_session_code(socket), do: socket
end
