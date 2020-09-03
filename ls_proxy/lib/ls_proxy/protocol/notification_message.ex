defmodule LsProxy.Protocol.NotificationMessage do
  @behaviour LsProxy.Protocol.JsonRPC

  defstruct [:method, :params]

  @callback method :: String.t()

  def build(method, params) do
    %__MODULE__{method: method, params: params}
  end

  @impl LsProxy.Protocol.JsonRPC
  def to_json_rpc(message) do
    Map.from_struct(message)
    |> LsProxy.Protocol.JsonRPC.build()
  end
end
