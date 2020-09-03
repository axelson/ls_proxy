defmodule LsProxy.RequestResponseTest do
  use ExUnit.Case, async: true

  ######
  # new/1
  ######
  test "new/1 with an incoming message that doesn't have an id" do
    raw_text = """
    Content-Length: 99
    Content-Type: utf-8

    {"jsonrpc":"2.0","method":"window/logMessage","params":{"message":"Started ElixirLS","type":4}}\r
    \r
    """

    message_record = LsProxy.MessageRecord.new(raw_text, :incoming)
    assert message_record.lsp_id == nil
    assert LsProxy.RequestResponse.new(message_record) == {:error, :no_id}
  end

  test "new/1 with an incoming message with an id" do
    message_record = LsProxy.Test.MessageRecordFixtures.incoming_hover_request()

    assert not is_nil(message_record.lsp_id)
    assert {:ok, req_resp} = LsProxy.RequestResponse.new(message_record)
    assert req_resp.status == :pending
  end

  test "new/1 with an outgoing messages with an id" do
    message_record = LsProxy.Test.MessageRecordFixtures.outgoing_code_lens_response()

    assert not is_nil(message_record.lsp_id)
    assert {:ok, req_resp} = LsProxy.RequestResponse.new(message_record)
    assert req_resp.status == :partial
  end

  ######
  # add/2
  ######
  describe "add/2 with cancellation" do
    setup do
      raw_text = """
      Content-Length: 168

      {"id":34,"jsonrpc":"2.0","method":"textDocument/codeLens","params":{"textDocument":{"uri":"file:///home/jason/dev/forks/elixir_ls_test/lib/elixir_ls_test/using.ex"}}}
      \r
      """

      incoming_request = LsProxy.MessageRecord.new(raw_text, :incoming)

      # We're currently not directly associating the cancel request with this
      # message chain because it does not have the same id
      # raw_text = """
      # Content-Length: 65

      # {"jsonrpc":"2.0","method":"$/cancelRequest","params":{"id":34}}
      # \r
      # """

      # cancel_incoming = LsProxy.MessageRecord.new(raw_text, :incoming)

      raw_text = """
      Content-Length: 81

      {"error":{"code":-32800,"message":"Request cancelled"},"id":34,"jsonrpc":"2.0"}
      \r
      """

      cancel_outgoing = LsProxy.MessageRecord.new(raw_text, :outgoing)

      raw_text = """
      Content-Length: 39

      {"id":34,"jsonrpc":"2.0","result":[]}
      \r
      """

      result_outgoing = LsProxy.MessageRecord.new(raw_text, :outgoing)

      %{
        incoming_request: incoming_request,
        cancel_outgoing: cancel_outgoing,
        result_outgoing: result_outgoing
      }
    end

    test "when the cancellation comes before the result", %{
      incoming_request: incoming_request,
      cancel_outgoing: cancel_outgoing,
      result_outgoing: result_outgoing
    } do
      assert {:ok, req_resp} = LsProxy.RequestResponse.new(incoming_request)
      assert req_resp.status == :pending

      assert {:ok, req_resp} = LsProxy.RequestResponse.add(req_resp, cancel_outgoing)
      assert req_resp.status == :canceled

      assert {:ok, req_resp} = LsProxy.RequestResponse.add(req_resp, result_outgoing)
      assert req_resp.status == :complete
    end

    test "when the result comes before the cancellation", %{
      incoming_request: incoming_request,
      cancel_outgoing: cancel_outgoing,
      result_outgoing: result_outgoing
    } do
      assert {:ok, req_resp} = LsProxy.RequestResponse.new(incoming_request)
      assert req_resp.status == :pending

      assert {:ok, req_resp} = LsProxy.RequestResponse.add(req_resp, result_outgoing)
      assert req_resp.status == :complete

      assert {:ok, req_resp} = LsProxy.RequestResponse.add(req_resp, cancel_outgoing)
      assert req_resp.status == :canceled
    end

    test "when the response comes before the result", %{
      incoming_request: incoming_request,
      cancel_outgoing: cancel_outgoing
    } do
      assert {:ok, req_resp} = LsProxy.RequestResponse.new(cancel_outgoing)
      assert req_resp.status == :partial

      assert {:ok, req_resp} = LsProxy.RequestResponse.add(req_resp, incoming_request)
      assert req_resp.status == :canceled
    end
  end
end
