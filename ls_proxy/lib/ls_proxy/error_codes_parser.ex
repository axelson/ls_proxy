defmodule LsProxy.ErrorCodesParser do
  @moduledoc """
  Parses Language Server Protocol error codes into a map of tuples. Reads the
  error code file from the priv directory. In the future there should be a
  script to generate the error code file.

  Example file:

      export namespace ErrorCodes {
        // Defined by JSON RPC
        export const ParseError: number = -32700;
        export const InvalidRequest: number = -32600;
        export const MethodNotFound: number = -32601;
        export const InvalidParams: number = -32602;
        export const InternalError: number = -32603;
        export const serverErrorStart: number = -32099;
        export const serverErrorEnd: number = -32000;
        export const ServerNotInitialized: number = -32002;
        export const UnknownErrorCode: number = -32001;

        // Defined by the protocol.
        export const RequestCancelled: number = -32800;
        export const ContentModified: number = -32801;
      }

  Would be parsed into:

      %{
        "ContentModified" => -32801,
        "InternalError" => -32603,
        "InvalidParams" => -32602,
        "InvalidRequest" => -32600,
        "MethodNotFound" => -32601,
        "ParseError" => -32700,
        "RequestCancelled" => -32800,
        "ServerNotInitialized" => -32002,
        "UnknownErrorCode" => -32001,
        "serverErrorEnd" => -32000,
        "serverErrorStart" => -32099
      }
  """

  @doc """
  Builds a map of error codes
  """
  def build_map, do: build_map(read_file())

  def build_map(file_contents) do
    file_contents
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.filter(&String.starts_with?(&1, "export const"))
    |> Map.new(&to_tuple/1)
  end

  @doc """
  iex> str = "export const ParseError: number = -32700;"
  iex> LsProxy.ErrorCodesParser.to_tuple(str)
  {"ParseError", -32700}
  """
  def to_tuple(str) do
    %{"identifier" => identifier, "num" => error_num} =
      Regex.named_captures(
        ~r/export const (?<identifier>\p{L}+): number = (?<num>-\p{Nd}+)/u,
        str
      )

    {identifier, String.to_integer(error_num)}
  end

  def read_file do
    :code.priv_dir(:ls_proxy)
    |> Path.join("error_codes.ts")
    |> File.read!()
  end
end
