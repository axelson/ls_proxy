defmodule LsProxy.MessageRecord do
  @moduledoc """
  The record of a message that was sent or received by a Language Protocol Server
  """

  @type direction :: :incoming | :outgoing
  @type t :: %__MODULE__{
    direction: direction,
    message: LsProxy.Protocol.Message.t(),
    timestamp: NaiveDateTime.t()
  }

  defstruct [:direction, :message, :timestamp]

  def new(raw_text, direction, now \\ NaiveDateTime.utc_now()) do
    {:ok, message} = LsProxy.ParserRunner.read_message(LsProxy.Protocol.Message, raw_text)

    %__MODULE__{
      message: message,
      direction: direction,
      timestamp: now
    }
  end
end
