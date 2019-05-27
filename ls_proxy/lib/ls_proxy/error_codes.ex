defmodule LsProxy.ErrorCodes do
  @moduledoc """
  Encapsulates access to Language Server Protocol Error Codes
  """

  @error_codes LsProxy.ErrorCodesParser.build_map()

  def map, do: @error_codes

  @doc """
  Get the error name for the given error code
  """
  def error_name(code)

  for {name, code} <- @error_codes do
    def error_name(unquote(code)), do: {:ok, unquote(name)}
  end

  def error_name(nil), do: {:error, :no_error_code_provided}
  def error_name(_), do: {:error, :invalid_error_code}
end
