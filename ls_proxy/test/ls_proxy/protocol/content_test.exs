defmodule LsProxy.Protocol.ContentTest do
  use ExUnit.Case
  alias LsProxy.Protocol.{Content, Header}
  alias LsProxyTest.Protocol.ParserHarness

  describe "Protocol.Parse behaviour" do
    test "parses a well-formed content" do
      content = """
      {"jsonrpc":"2.0","method":"window/logMessage","params":{"message":"Started ElixirLS","type":4}}

      """
      |> String.replace("\n", "\r\n")

      header = %Header{content_length: 99}

      assert ParserHarness.read_message(Content, content, header) ==
               {:ok,
                %{
                  "jsonrpc" => "2.0",
                  "method" => "window/logMessage",
                  "params" => %{"message" => "Started ElixirLS", "type" => 4}
                }}
    end

    test "fails when the length is correct but the json is mal-formed" do
      content = """
      ["jsonrpc":"2.0","method":"window/logMessage","params":{"message":"Started ElixirLS","type":4}}\r
      \r
      """

      header = %Header{content_length: 99}

      assert {:error, %Jason.DecodeError{}} = ParserHarness.read_message(Content, content, header)
    end

    test "fails when the length is incorrect" do
      content = """
      {"jsonrpc":"2.0","method":"window/logMessage","params":{"message":"Started ElixirLS","type":4}}\r
      \r
      """

      header = %Header{content_length: 10}

      assert {:error, %Jason.DecodeError{}} = ParserHarness.read_message(Content, content, header)
    end
  end
end
