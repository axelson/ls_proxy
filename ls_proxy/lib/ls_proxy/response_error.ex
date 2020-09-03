defmodule LsProxy.ResponseError do
  @moduledoc """
  Language Server Protocol `ResponseError` message

  https://microsoft.github.io/language-server-protocol/specification#response-message
  """

  @type t :: %__MODULE__{
          error_name: String.t(),
          message: String.t(),
          data: any
        }

  defstruct [:error_name, :message, :data]

  @doc """
      iex> LsProxy.ResponseError.new(%{"code" => -32800, "message" => "Request cancelled"})
      {:ok, %LsProxy.ResponseError{error_name: "RequestCancelled", message: "Request cancelled", data: nil}}
  """
  def new(error_map) do
    case LsProxy.ErrorCodes.error_name(error_map["code"]) do
      {:ok, error_name} ->
        {:ok,
         %LsProxy.ResponseError{
           error_name: error_name,
           message: error_map["message"],
           data: error_map["data"]
         }}

      {:error, _} = err ->
        err
    end
  end
end
