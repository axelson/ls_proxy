use Mix.Config

config :lspp_web, LsppWebWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  # code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../../lspp_web/assets", __DIR__)
    ]
  ]

# need to adjust these for this app

# Watch static and templates for browser reloading.
config :lspp_web, LsppWebWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"../lspp_web/priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"../lspp_web/priv/gettext/.*(po)$",
      ~r"../lspp_web/lib/lspp_web_web/{live,views}/.*(ex)$",
      ~r"../lspp_web/lib/lspp_web_web/templates/.*(eex)$",
      ~r{../lspp_web/lib/lspp_web_web/live/.*(ex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :exsync,
  extensions: [".erl", ".hrl", ".ex", ".leex", ".eex"],
  reload_timeout: 75,
  reload_callback: {LsProxy.ProxyState, :kill_listeners, []}
