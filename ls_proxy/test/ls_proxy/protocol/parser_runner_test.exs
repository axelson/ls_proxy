defmodule LsProxy.Protocol.ParserRunnerTest do
  # Does this async actually do anything?
  use ExUnit.Case, async: true
  alias LsProxy.ParserRunner
  alias LsProxy.Protocol

  @complete_message """
  Content-Length: 52
  Content-Type: utf-8

  {"jsonrpc":"2.0","method":"initialized","params":{}}
  """

  @other "Content-Length: 99\r\n\r\n{\"jsonrpc\":\"2.0\",\"method\":\"window/logMessage\",\"params\":{\"message\":\"Started ElixirLS\",\"type\":4}}\r\n\r\n"

  @incomplete_message """
  Content-Length: 131

  {"jsonrpc":"2.0","method":"window/logMessage","params":{"message":"Elixir version: \\"1.6
  """

  test "can parse a complete message from a string" do
    assert {:ok, message} = ParserRunner.read_message(Protocol.Message, @complete_message)

    assert message == %LsProxy.Protocol.Message{
             content: %{
               "jsonrpc" => "2.0",
               "method" => "initialized",
               "params" => %{}
             },
             header: %LsProxy.Protocol.Header{content_length: 52, content_type: :utf8}
           }
  end

  test "other" do
    assert {:ok, _message} = ParserRunner.read_message(Protocol.Message, @other)
  end

  test "can parse from a file" do
    file_path = "../data/short.txt"
    string = File.read!(file_path)

    assert {:ok, message} = ParserRunner.read_message(Protocol.Message, string)
    assert message == %LsProxy.Protocol.Message{
      content: %{
        "jsonrpc" => "2.0",
        "method" => "initialized",
        "params" => %{}
      },
      header: %LsProxy.Protocol.Header{content_length: 52, content_type: :utf8}
    }
  end

  test "returns an error with when an incomplete message is received" do
    assert {:error, error} = ParserRunner.read_message(Protocol.Message, @incomplete_message)
    assert error == "not_enough_input. Wanted 131. Got: 89"
  end
end
