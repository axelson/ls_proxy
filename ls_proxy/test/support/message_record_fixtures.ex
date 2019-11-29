defmodule LsProxy.Test.MessageRecordFixtures do
  def incoming_hover_request do
    raw_text =
      """
      {"id":40,"jsonrpc":"2.0","method":"textDocument/hover","params":{"position":{"character":21,"line":1},"textDocument":{"uri":"file:///home/jason/dev/forks/elixir_ls_test/lib/elixir_ls_test/using.ex"}}}
      """
      |> add_header()

    LsProxy.MessageRecord.new(raw_text, :incoming)
  end

  def outgoing_code_lens_response do
    raw_text =
      """
      {"id":41,"jsonrpc":"2.0","result":[]}
      """
      |> add_header()

    LsProxy.MessageRecord.new(raw_text, :outgoing)
  end

  defp add_header(raw_text) do
    length = String.length(raw_text)

    """
    Content-Length: #{length}

    #{raw_text}
    """
  end
end
