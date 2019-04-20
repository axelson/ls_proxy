defmodule LsProxy.Application do
  use Application

  def start(_type, _args) do
    children = [
      {ErlexecInit, []},
      {LsProxy.ProxyState, []},
      {Registry, [keys: :unique, name: LsProxy.MessageRegistry]}
    ]
    |> maybe_add_proxy_port()

    opts = [strategy: :one_for_one, name: LsProxy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp maybe_add_proxy_port(children) do
    if Application.get_env(:ls_proxy, :proxy_to) != "none" do
      [{LsProxy.ProxyPort, []} | children]
    else
      children
    end
  end
end
