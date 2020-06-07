defmodule LsProxy.Methods.TextDocumentHoverMethod do
  @behaviour LsProxy.Methods

  @impl LsProxy.Methods
  def extra_info(message) do
    # request = %LsProxy.Protocol.Message{
    #   content: %{
    #     "id" => 9,
    #     "jsonrpc" => "2.0",
    #     "method" => "textDocument/hover",
    #     "params" => %{
    #       "position" => %{"character" => 8, "line" => 4},
    #       "textDocument" => %{
    #         "uri" => "file:///home/jason/dev/pomodoro/lib/pomodoro_ui.ex"
    #       }
    #     }
    #   },
    #   header: %LsProxy.Protocol.Header{content_length: 177, content_type: :utf8}
    # }

    %LsProxy.Protocol.Message{content: content} = message
    %{"line" => line, "character" => character} = content["params"]["position"]
    uri = content["params"]["textDocument"]["uri"]
    uri = URI.parse(uri)

    case annotate(uri.path, line, character) do
      {:ok, text} ->
        text

      {:error, _error} ->
        nil
    end
  end

  def annotate(path, line, character) do
    with {:ok, text} <- read_file_line(path, line) do
      pointer_line = String.duplicate(" ", character) <> "^"
      {:ok, text <> pointer_line}
    end
  end

  def read_file_line(path, line) do
    File.stream!(path, [:read, :utf8], :line)
    |> Stream.drop(line)
    |> Enum.take(1)
    |> hd()
    |> Utils.wrap_in_ok()
  rescue
    e in File.Error ->
      {:error, e}
  end
end
