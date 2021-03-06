# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :cableclub,
  namespace: CableClub,
  ecto_repos: [CableClub.Repo]

# Configures the endpoint
config :cableclub, CableClubWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "OpGvh4oaCZgdkXH76kIKraBk1ccXDgb4d1ZxUk6cAp1I8aCZdHFdr+X74apOsEJg",
  render_errors: [view: CableClubWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: CableClub.PubSub,
  live_view: [signing_salt: "KDFThAEw"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason
config :phoenix, :template_engines, md: PhoenixMarkdown.Engine

if discord_client_id = System.get_env("DISCORD_CLIENT_ID") do
  config :cableclub, CableClubWeb.OAuth.Discord, client_id: discord_client_id
end

if discord_client_secret = System.get_env("DISCORD_CLIENT_SECRET") do
  config :cableclub, CableClubWeb.OAuth.Discord, client_secret: discord_client_secret
end

config :cableclub, CableClubWeb.OAuth.Discord, url: "http://localhost:4000/oauth/discord"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
