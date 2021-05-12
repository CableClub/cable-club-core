defmodule CableClub.Repo do
  use Ecto.Repo,
    otp_app: :cableclub,
    adapter: Ecto.Adapters.Postgres
end
