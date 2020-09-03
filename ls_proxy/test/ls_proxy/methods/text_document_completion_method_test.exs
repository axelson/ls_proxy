defmodule LsProxy.Methods.TextDocumentCompletionMethodTest do
  use ExUnit.Case, async: true

  alias LsProxy.Methods.TextDocumentCompletionMethod

  test "extra_info/1" do
    path = Path.join(__DIR__, "../../support/example_source_file.ex") |> Path.expand()

    message = %LsProxy.Protocol.Message{
      content: %{
        "id" => 1555,
        "jsonrpc" => "2.0",
        "method" => "textDocument/completion",
        "params" => %{
          "context" => %{"triggerKind" => 1},
          "position" => %{"character" => 22, "line" => 6},
          "textDocument" => %{
            "uri" => "file://#{path}"
          }
        }
      },
      header: %LsProxy.Protocol.Header{content_length: 238, content_type: :utf8}
    }

    assert TextDocumentCompletionMethod.extra_info(message) ==
             "    IO.puts(\"Greetings\")\n                      ^"
  end
end
