# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :lspp_web, LsppWebWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "pAh0tCJVLmkqArygsff6OuwR6LCbMZj5XUAq3qGjVy/hil54UKPaK0/bDa06Sps8",
  render_errors: [view: LsppWebWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: LsppWeb.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "5itHJeTZaUHrXCWtNeWQVM0IzZKWiVfM"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
