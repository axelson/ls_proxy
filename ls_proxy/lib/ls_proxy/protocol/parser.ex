defmodule LsProxy.Protocol.Parser do
  @moduledoc """
  Behaviour for parsing content

  The `read/2` function takes input and then asks for commands to be run. It is
  then called again with tout output of the requested command.
  """

  @type state :: any
  @type command :: :read_line | {:read_bytes, non_neg_integer}

  @callback read(state, input :: any) :: {:ok, state, command}
end
