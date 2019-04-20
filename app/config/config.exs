use Mix.Config

config :lspp_web, LsppWebWeb.Endpoint,
  url: [host: "localhost"],
  server: true,
  secret_key_base: "pAh0tCJVLmkqArygsff6OuwR6LCbMZj5XUAq3qGjVy/hil54UKPaK0/bDa06Sps8",
  render_errors: [view: LsppWebWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: LsppWeb.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "5itHJeTZaUHrXCWtNeWQVM0IzZKWiVfM"
  ]

config :ls_proxy, http_proxy_to: System.get_env("LS_HTTP_PROXY_TO")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
