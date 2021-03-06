defmodule CableClub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      CableClub.Repo,
      # Start the Telemetry supervisor
      CableClubWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: CableClub.PubSub},
      # Start Session system
      CableClub.Pokemon.Gen1.SessionSupervisor,
      # Start the Endpoint (http/https)
      CableClubWeb.Endpoint
      # Start a worker by calling: CableClub.Worker.start_link(arg)
      # {CableClub.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CableClub.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CableClubWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
