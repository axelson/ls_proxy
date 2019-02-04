defmodule LsProxy.Protocol.Content do
  @behaviour LsProxy.Protocol.Parser
  @impl LsProxy.Protocol.Parser

  alias LsProxy.Protocol

  def read(:init, %Protocol.Header{content_length: content_length}) do
    {:ok, :started, {:read_bytes, content_length}}
  end

  def read(:started, content_text) do
    case parse(content_text) do
      {:ok, json} -> {:ok, :done, json}
      {:error, message} -> {:error, message}
    end
  end

  def parse(content_text) do
    Jason.decode(content_text)
  end
end
