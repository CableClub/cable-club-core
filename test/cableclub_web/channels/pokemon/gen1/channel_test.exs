defmodule CableClubWeb.Pokemon.Gen1.ChannelTest do
  use CableClubWeb.ChannelCase
  alias CableClub.AccountsFixtures
  alias CableClubWeb.Pokemon.Gen1.{Socket, Channel}
  alias CableClub.Pokemon.Gen1.{SessionSupervisor, SessionManager, Session}

  setup do
    user = AccountsFixtures.user_fixture()

    {:ok, _, socket} =
      Socket
      |> socket("pokemon.gen1.socket.#{user.id}", %{user: user})
      |> subscribe_and_join(Channel, "v1")

    %{socket: socket}
  end

  test "session.create adds a session to the registry", %{socket: socket} do
    ref = push(socket, "session.create", %{})
    assert_reply ref, :ok, %{code: code}
    assert SessionSupervisor.find_child(code)
  end

  test "session.join joins an existing session", %{socket: socket} do
    # implicitly joins the test processes to the session
    {:ok, session} = SessionManager.new(make_ref())
    code = SessionManager.code(session)

    ref = push(socket, "session.join", %{"code" => code})
    assert_reply ref, :ok

    # dispatched by the session when two processes join
    assert_receive {Session, "session.status", %{"ready" => true}}
    assert_push "session.status", %{"ready" => true}
  end

  test "session.start success", %{socket: socket} do
    {:ok, session} = SessionManager.new(make_ref())
    code = SessionManager.code(session)
    ref = push(socket, "session.join", %{"code" => code})
    assert_reply ref, :ok
    assert_receive {Session, "session.status", %{"ready" => true}}
    assert_push "session.status", %{"ready" => true}

    # start a trade session
    assert :ok = SessionManager.start(session, "trade")
    # confirm the trade session
    ref = push(socket, "session.start", %{"type" => "trade"})
    assert_reply ref, :ok
  end

  test "session.start error", %{socket: socket} do
    {:ok, session} = SessionManager.new(make_ref())
    code = SessionManager.code(session)
    ref = push(socket, "session.join", %{"code" => code})
    assert_reply ref, :ok
    assert_receive {Session, "session.status", %{"ready" => true}}
    assert_push "session.status", %{"ready" => true}

    # start a trade session
    assert :ok = SessionManager.start(session, "trade")
    # try to start a different type
    ref = push(socket, "session.start", %{"type" => "battle"})
    assert_reply ref, :error, %{reason: "session type disagreement"}
  end

  test "session.transfer in a valid session state", %{socket: socket} do
    {:ok, session} = SessionManager.new(make_ref())
    code = SessionManager.code(session)
    ref = push(socket, "session.join", %{"code" => code})
    assert_reply ref, :ok
    assert_receive {Session, "session.status", %{"ready" => true}}
    assert_push "session.status", %{"ready" => true}
    assert :ok = SessionManager.start(session, "trade")
    ref = push(socket, "session.start", %{"type" => "trade"})
    assert_reply ref, :ok
    assert :ok = SessionManager.transfer(session, 0x69)
    assert_push("session.transfer", %{"data" => 0x69})

    ref = push(socket, "session.transfer", %{"data" => 0xFE})
    assert_reply ref, :ok

    assert_receive {Session, "session.transfer", %{"data" => 0xFE}}
  end

  test "session.transfer without joining or creating a session", %{socket: socket} do
    ref = push(socket, "session.transfer", %{"data" => 0xFE})
    assert_reply ref, :error, %{reason: "no session"}
  end

  test "session.transfer in invalid session state", %{socket: socket} do
    ref = push(socket, "session.create", %{})
    assert_reply ref, :ok, %{code: _code}
    ref = push(socket, "session.transfer", %{"data" => 0xFE})
    assert_reply ref, :error, %{reason: "session not ready"}
  end

  test "session.transfer invalid data", %{socket: socket} do
    {:ok, session} = SessionManager.new(make_ref())
    code = SessionManager.code(session)
    ref = push(socket, "session.join", %{"code" => code})
    assert_reply ref, :ok
    assert_receive {Session, "session.status", %{"ready" => true}}
    assert_push "session.status", %{"ready" => true}
    assert :ok = SessionManager.start(session, "trade")
    ref = push(socket, "session.start", %{"type" => "trade"})
    assert_reply ref, :ok

    ref = push(socket, "session.transfer", %{"data" => 0xFFFF})
    assert_reply ref, :error, %{reason: "invalid data"}
  end
end
