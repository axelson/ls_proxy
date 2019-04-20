defmodule LsppWebWeb.MessagesController do
  use LsppWebWeb, :controller

  def create(conn, %{"message" => message}) do
    :ok = LsProxy.ProxyState.record_incoming(message)

    conn
    |> json(%{ok: true})
  end

  def create(conn, _params) do
    conn
    |> json(%{error: "Missing message param"})
  end
end
