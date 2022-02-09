defmodule LsProxy.Protocol.Message do
  @moduledoc """
  Represents a Language Server Protocol message. Contains a header and content
  """

  @behaviour LsProxy.Protocol.Parser
  @enforce_keys [:header, :content]
  defstruct [:header, :content]

  @type t :: %__MODULE__{
          header: map(),
          content: map()
        }

  alias LsProxy.Protocol

  @impl Protocol.Parser
  def read(:init, _input) do
    {:ok, header_state, command} = Protocol.Header.read(:init, nil)
    {:ok, {:header, header_state}, command}
  end

  def read({:header, header_state}, line) do
    case Protocol.Header.read(header_state, line) do
      {:ok, :done, header} ->
        {:ok, content_state, command} = Protocol.Content.read(:init, header)
        {:ok, {:content, content_state, header}, command}

      {:ok, header_state, command} ->
        {:ok, {:header, header_state}, command}

      {:error, message} ->
        {:error, message}
    end
  end

  def read({:content, content_state, header}, input) do
    case Protocol.Content.read(content_state, input) do
      {:ok, :done, content} ->
        {:ok, :done, %__MODULE__{header: header, content: content}}

      {:error, %Jason.DecodeError{data: data} = error} ->
        # This is not an expectd case
        # The problem that appears to be triggering this issue on message_view.ex is probably the -> emoji
        LsProxy.Logger.info("Failed to decode JSON")
        LsProxy.Logger.info(data)

        {:error, error}
    end
  end

  def to_string(%__MODULE__{} = message) do
    message_content = Protocol.Content.to_string(message.content)

    """
    Content-Length: #{byte_size(message_content)}\r
    \r
    #{message_content}
    """
    |> String.trim()
  end

  defimpl String.Chars, for: __MODULE__ do
    def to_string(message) do
      LsProxy.Protocol.Message.to_string(message)
    end
  end

  # TODO: Split the parsing from the operations on the finished data structure
  @doc """
  Returns the method name, or nil if it doesn't exist
  """
  def method(%__MODULE__{content: content}) do
    content["method"]
  end
end
