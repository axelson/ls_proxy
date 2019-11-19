# This still feels like it should be a protocol...
defmodule LsProxy.Protocol.JsonRPC do
  defstruct [:message]

  alias LsProxy.Protocol

  @callback to_json_rpc(data :: any) :: map

  def build(message) do
    %__MODULE__{message: message}
  end

  def to_string(rpc_message) do
    %__MODULE__{message: message} = rpc_message
    message = Map.put(message, :jsonrpc, "2.0")

    # HACK: Use a content_length of 1 because the actual used content_length
    # is generated inside of `LsProxy.Protocol.Message`
    header = %Protocol.Header{content_length: 1}

    %Protocol.Message{
      header: header,
      content: message
    }
    |> Kernel.to_string()
  end

  defimpl String.Chars, for: __MODULE__ do
    def to_string(rpc_message) do
      LsProxy.Protocol.JsonRPC.to_string(rpc_message)
    end
  end
end

defprotocol LsProxy.Protocol.JsonRPC.Protocol do
  def to_rpc_message(message)
end
