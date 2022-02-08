import Config

# Configures the endpoint
config :lspp_web, LsppWebWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "pAh0tCJVLmkqArygsff6OuwR6LCbMZj5XUAq3qGjVy/hil54UKPaK0/bDa06Sps8",
  render_errors: [view: LsppWebWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: LsppWeb.PubSub,
  live_view: [
    signing_salt: "5itHJeTZaUHrXCWtNeWQVM0IzZKWiVfM"
  ]

config :lspp_web,
  static_assets: :dynamic

# When we run lspp_web directly we aren't doing actual proxying
config :ls_proxy,
  run_language_server: "false",
  proxy_to: "none",
  http_proxy_to: nil

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
