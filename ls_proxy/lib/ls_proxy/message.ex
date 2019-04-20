defmodule LsProxy.Message do
  @moduledoc """
  Represents a message sent or received by a Language Protocol Server
  """

  @type direction :: :incoming | :outgoing
  @type t :: %__MODULE__{
    direction: direction,
    raw_text: String.t(),
    timestamp: NaiveDateTime.t()
  }

  defstruct [:direction, :raw_text, :timestamp]

  def new(raw_text, direction, now \\ NaiveDateTime.utc_now()) do
    %__MODULE__{
      raw_text: raw_text,
      direction: direction,
      timestamp: now
    }
  end
end
