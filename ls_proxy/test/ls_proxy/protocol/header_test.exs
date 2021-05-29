defmodule LsProxy.Protocol.HeaderTest do
  use ExUnit.Case
  alias LsProxy.Protocol.Header
  alias LsProxyTest.Protocol.ParserHarness

  describe "Protocol.Parse behaviour" do
    test "parses a new header" do
      header_text = """
      Content-Length: 99
      Content-Type: application/vscode-jsonrpc; charset=utf-8
      """

      assert ParserHarness.read_message(Header, header_text) ==
               {:ok, %Header{content_length: 99, content_type: :default_content_type}}
    end

    test "parses a complete header" do
      header_text = """
      Content-Length: 99
      Content-Type: utf-8
      """

      assert ParserHarness.read_message(Header, header_text) ==
               {:ok, %Header{content_length: 99, content_type: :utf8}}
    end

    test "parses a header from a full message" do
      header_text = """
      Content-Length: 99
      Content-Type: utf-8

      {"jsonrpc":"2.0","method":"window/logMessage","params":{"message":"Started ElixirLS","type":4}}
      """

      assert ParserHarness.read_message(Header, header_text) ==
               {:ok, %Header{content_length: 99, content_type: :utf8}}
    end

    test "returns an error on a mal-formed header" do
      header_text = """
      Length: 99
      """

      assert ParserHarness.read_message(Header, header_text) ==
               {:error, [:unrecognized_field]}
    end
  end
end
