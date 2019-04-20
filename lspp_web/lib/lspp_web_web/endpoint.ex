defmodule LsppWebWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :lspp_web

  socket "/socket", LsppWebWeb.UserSocket,
    websocket: true,
    longpoll: false

  socket "/live", Phoenix.LiveView.Socket

  # Disabling Plug.Static because we can't use it with escript's (and maybe
  # releases)
  # plug Plug.Static,
  #   at: "/",
  #   from: :lspp_web,
  #   gzip: false,
  #   only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_lspp_web_key",
    signing_salt: "GfSf47g8"

  plug LsppWebWeb.Router
end
