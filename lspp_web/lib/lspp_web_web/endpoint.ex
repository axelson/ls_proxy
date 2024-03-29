defmodule LsppWebWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :lspp_web

  @session_options [
    store: :cookie,
    key: "_lspp_web_key",
    signing_salt: "GfSf47g8"
  ]

  socket "/socket", LsppWebWeb.UserSocket,
    websocket: true,
    longpoll: false

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Disabling Plug.Static because we can't use it with escript's (and maybe
  # releases)
  if Application.fetch_env!(:lspp_web, :static_assets) == :dynamic do
    plug Plug.Static,
      at: "/",
      from: :lspp_web,
      gzip: false,
      only: ~w(assets fonts images favicon.ico robots.txt)
  end

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
       @session_options

  plug LsppWebWeb.Router

  def init(_supervisor, config) do
    port = LsppWeb.PhoenixPortSupervisor.get_port()
    config = put_in(config[:http], [:inet6, {:port, port}])

    {:ok, config}
  end
end
