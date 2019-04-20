defmodule LsProxy.Application do
  use Application

  def start(_type, _args) do
    children = [
      {ErlexecInit, []},
      {LsProxy.ProxyState, []},
      {LsProxy.ProxyPort, []},
      {Registry, [keys: :unique, name: LsProxy.MessageRegistry]}
    ]

    opts = [strategy: :one_for_one, name: LsProxy.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
