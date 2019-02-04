defmodule LsProxy.Protocol.Message do
  @moduledoc """
  Represents a Language Server Protocol message. Contains a header and content
  """

  @behaviour LsProxy.Protocol.Parser
  @enforce_keys [:header, :content]
  defstruct [:header, :content]

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
    end
  end

  # def read({:content, header}, content_text) do
  #   {:ok, content} = Protocol.Content.parse(content_text)
  #   {:ok, :done, %__MODULE__{header: header, content: content}}
  # end
end
