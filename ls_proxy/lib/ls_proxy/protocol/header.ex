defmodule LsProxy.Protocol.Header do
  @moduledoc """
  Represents a Language Server Protocol Header
  """

  @behaviour LsProxy.Protocol.Parser
  @enforce_keys [:content_length]
  defstruct [:content_length, content_type: :utf8]

  alias LsProxy.LsProxyUtils

  @header_fields [
    {"Content-Length", :content_length, &__MODULE__.parse_content_length/1},
    {"Content-Type", :content_type, &__MODULE__.parse_content_type/1}
  ]

  @impl LsProxy.Protocol.Parser
  def read(:init, _input) do
    {:ok, {:started, []}, :read_line}
  end

  def read({:started, lines}, line) do
    case line do
      "\r\n" -> done(lines)
      "\n" -> done(lines)
      :eof -> done(lines, :eof)
      _line -> {:ok, {:started, [line | lines]}, :read_line}
    end
  end

  defp done([], :eof), do: {:error, :eof}
  defp done(lines, _), do: done(lines)

  defp done(lines) do
    case parse(lines) do
      {:ok, struct} -> {:ok, :done, struct}
      {:error, errors} -> {:error, errors}
    end
  end

  def parse([]), do: {:error, :no_content}

  def parse(header_text) do
    header_text
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_header_field/1)
    |> LsProxyUtils.collect_successes()
    |> case do
      {:ok, struct_fields} ->
        {:ok, struct(__MODULE__, struct_fields)}

      {:error, errors} ->
        {:error, errors}
    end
  end

  for {field_name, field_atom, field_function} <- @header_fields do
    # LSP headers consist of the header name followed by ": " then the value
    defp parse_header_field("#{unquote(field_name)}: " <> value) do
      {:ok, {unquote(field_atom), unquote(field_function).(value)}}
    end
  end

  defp parse_header_field(_), do: {:error, :unrecognized_field}

  def parse_content_length(string), do: String.to_integer(string)

  def parse_content_type("utf-8"), do: :utf8

  # For backwards compatibility it is highly recommended that a client and a server treats the string utf8 as utf-8
  def parse_content_type("utf8"), do: :utf8

  # This could be DRYer
  def to_string(%__MODULE__{} = header) do
    """
    Content-Length: #{header.content_length}
    Content-Type: utf-8
    """
    |> String.trim()
  end
end
