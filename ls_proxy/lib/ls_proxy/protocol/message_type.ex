defmodule LsProxy.Protocol.MessageType do
  @moduledoc """
  export namespace MessageType {
    /**
    * An error message.
    */
    export const Error = 1;
    /**
    * A warning message.
    */
    export const Warning = 2;
    /**
    * An information message.
    */
    export const Info = 3;
    /**
    * A log message.
    */
    export const Log = 4;
  }
  """

  def type(:error), do: 1
  def type(:warning), do: 2
  def type(:info), do: 3
  def type(:log), do: 4
end
