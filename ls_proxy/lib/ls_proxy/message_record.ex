defmodule LsProxy.MessageRecord do
  @moduledoc """
  The record of a message that was sent or received by a Language Protocol Server
  """

  @type direction :: :incoming | :outgoing
  @type t :: %__MODULE__{
    id: integer,
    lsp_id: integer | nil,
    direction: direction,
    message: LsProxy.Protocol.Message.t(),
    timestamp: NaiveDateTime.t()
  }

  defstruct [:id, :lsp_id, :direction, :message, :timestamp]

  def new(raw_text, direction, now \\ NaiveDateTime.utc_now()) do
    {:ok, message} = LsProxy.ParserRunner.read_message(LsProxy.Protocol.Message, raw_text)

    %__MODULE__{
      id: System.unique_integer([:positive, :monotonic]),
      lsp_id: lsp_id(message.content),
      message: message,
      direction: direction,
      timestamp: now
    }
  end

  # Not all messages have id's (e.g. Notification Messages)
  # https://microsoft.github.io/language-server-protocol/specification#notification-message
  defp lsp_id(%{"id" => id}), do: id
  defp lsp_id(_), do: nil
end
