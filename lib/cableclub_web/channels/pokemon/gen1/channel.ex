defmodule CableClubWeb.Pokemon.Gen1.Channel do
  @moduledoc """
  Channel for trading and battling gen1 pokemon

  Client connection flow should be something like:

  * `session.create` or `session.join` to bridge two connections
  * `session.start` to sync two connections
  * `session.transfer` bytes
  """

  use CableClubWeb, :channel
  alias CableClub.Pokemon.Gen1.{SessionManager, Session}

  @impl true
  def join(_topic, _params, socket) do
    {:ok,
     socket
     |> assign(:session, nil)}
  end

  @impl true
  def handle_in("session.create", _payload, socket) do
    case SessionManager.new(socket_ref(socket)) do
      {:ok, session} ->
        code = SessionManager.code(session)
        {:reply, {:ok, %{code: code}}, socket |> assign(:session, session)}

      {:error, reason} ->
        {:reply, {:error, %{reason: reason}}, socket |> assign(:session, nil)}
    end
  end

  def handle_in("session.join", %{"code" => code}, socket) do
    case SessionManager.join(socket_ref(socket), code) do
      {:ok, session} ->
        {:reply, {:ok, %{}}, socket |> assign(:session, session)}

      {:error, reason} ->
        {:reply, {:error, %{reason: reason}}, socket |> assign(:session, nil)}
    end
  end

  def handle_in("session.start", _, %{assigns: %{session: nil}} = socket) do
    {:reply, {:error, %{reason: "no session"}}, socket}
  end

  def handle_in("session.start", %{"type" => type}, socket) do
    case SessionManager.start(socket.assigns.session, type) do
      :ok ->
        {:reply, {:ok, %{}}, socket}

      {:error, reason} ->
        {:reply, {:error, %{reason: reason}}, socket}
    end
  end

  def handle_in("session.stop", _, socket) do
    case SessionManager.stop(socket.assigns.session) do
      :ok ->
        {:reply, {:ok, %{}}, socket}

      {:error, reason} ->
        {:reply, {:error, %{reason: reason}}, socket}
    end
  end

  def handle_in("session.transfer", %{"data" => _data}, %{assigns: %{session: nil}} = socket) do
    {:reply, {:error, %{reason: "no session"}}, socket}
  end

  def handle_in("session.transfer", %{"data" => data}, socket) when data in 0..0xFF do
    case SessionManager.transfer(socket.assigns.session, data) do
      :ok ->
        {:reply, {:ok, %{}}, socket}

      {:error, reason} ->
        {:reply, {:error, %{reason: reason}}, socket}
    end
  end

  def handle_in("session.transfer", _, socket) do
    {:reply, {:error, %{reason: "invalid data"}}, socket}
  end

  @impl true
  def handle_info({Session, "session.status", status}, socket) do
    push(socket, "session.status", status)
    {:noreply, socket}
  end

  def handle_info({Session, "session.transfer", data}, socket) do
    push(socket, "session.transfer", data)
    {:noreply, socket}
  end
end
