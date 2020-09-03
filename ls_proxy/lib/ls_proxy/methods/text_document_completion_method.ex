defmodule LsProxy.Methods.TextDocumentCompletionMethod do
  @behaviour LsProxy.Methods

  @impl LsProxy.Methods
  def extra_info(message) do
    %LsProxy.Protocol.Message{content: content} = message
    %{"line" => line, "character" => character} = content["params"]["position"]
    uri = content["params"]["textDocument"]["uri"]
    uri = URI.parse(uri)

    case annotate(uri.path, line, character) do
      {:ok, text} ->
        text

      {:error, _error} ->
        nil

      _ ->
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
    with stream <- File.stream!(path, [:read, :utf8], :line),
         stream <- Stream.drop(stream, line),
         [line] <- Enum.take(stream, 1) do
      {:ok, line}
    end
  rescue
    e in File.Error ->
      {:error, e}
  end
end
