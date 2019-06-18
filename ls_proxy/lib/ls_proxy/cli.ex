defmodule LsProxy.CLI do
  @moduledoc """
  Orchestrates starting up LsProxy as a command line program that receives stdin
  and writes to stdout.
  """

  alias LsProxy.Protocol

  def main(_args) do
    # Node.set_cookie :cookie
    LsProxy.Logger.info("Started node: #{inspect({Node.self, Node.get_cookie})}")
    read_messages()
  end

  @doc """
  Reads message from stdio until stdio is closed. Forwards the responses to the
  LS and prints the responses back to stdout

  TODO: Should this module be responsible for sending the messages back to stdout? Maybe that should be in a GenServer
  """
  def read_messages() do
    LsProxy.Logger.info "LsProxy.CLI read_messages"
    case LsProxy.ParserRunner.read_message(Protocol.Message, :stdio) do
      {:ok, %Protocol.Message{} = message} ->
        str = Protocol.Message.to_string(message)
        LsProxy.Logger.info ["Editor->LS:\n", str]

        # Get actual response
        :ok = LsProxy.ProxyPort.send_message(str)

        read_messages()

      {:error, :no_content} ->
        LsProxy.Logger.info "no content"
        Process.sleep(1000)

      {:error, :eof} ->
        LsProxy.Logger.info "DONE!"
    end
  end
end
