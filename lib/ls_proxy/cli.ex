defmodule LsProxy.CLI do
  @moduledoc """
  Orchestrates starting up LsProxy as a command line program that receives stdin
  and writes to stdout.
  """

  alias LsProxy.Protocol

  def main(_args) do
    read_messages()
  end

  def read_messages() do
    case LsProxy.ParserRunner.read_message(Protocol.Message, :stdio) do
      {:ok, %Protocol.Message{} = message} ->
        IO.inspect(message, label: "message")
        read_messages()

      {:error, :no_content} ->
        IO.puts "no content"
        Process.sleep(1000)

      {:error, :eof} ->
        IO.puts "DONE!"
    end
  end
end
