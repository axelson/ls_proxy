defmodule LsProxy.Protocol.Messages.WindowLogMessage do
  @moduledoc """
  Creates `window/logMessage` messages

  Example message:

      Content-Length: 95
      Content-Type: utf-8

      {"jsonrpc":"2.0","method":"window/logMessage","params":{"message":"Started ElixirLS","type":4}}

  Formatted content:

    {
      "jsonrpc": "2.0",
      "method": "window/logMessage",
      "params": {
        "message": "Started ElixirLS",
        "type":4
      }
    }

  Interface:

      interface LogMessageParams {
        /**
        * The message type. See {@link MessageType}
        */
        type: number;

        /**
        * The actual message
        */
        message: string;
      }
  """

  @method "window/logMessage"

  @behaviour LsProxy.Protocol.NotificationMessage

  defstruct [:type, :message]

  alias LsProxy.Protocol

  @impl LsProxy.Protocol.NotificationMessage
  def method, do: @method

  def build(message_text, level \\ :log) when is_binary(message_text) do
    %__MODULE__{
      type: Protocol.MessageType.type(level),
      message: message_text
    }
  end

  defimpl LsProxy.Protocol.JsonRPC.Protocol, for: __MODULE__ do
    def to_rpc_message(message) do
      method = LsProxy.Protocol.Messages.WindowLogMessage.method()

      params = %{
        type: message.type,
        message: message.message
      }

      LsProxy.Protocol.NotificationMessage.build(method, params)
      |> LsProxy.Protocol.NotificationMessage.to_json_rpc()
    end
  end
end
