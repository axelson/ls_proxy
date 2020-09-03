defmodule LsProxy.MessageRecord do
  @moduledoc """
  The record of a message that was sent or received by a Language Protocol Server
  """

  @type direction :: :incoming | :outgoing
  @type t :: %__MODULE__{
          id: integer,
          lsp_id: integer | nil,
          direction: direction,
          error: LsProxy.ResponseError.t() | nil,
          message: LsProxy.Protocol.Message.t(),
          timestamp: NaiveDateTime.t(),
          extra_info: String.t()
        }

  defstruct [:id, :lsp_id, :direction, :error, :message, :timestamp, :extra_info]

  def new(raw_text, direction, now \\ NaiveDateTime.utc_now()) do
    {:ok, message} = LsProxy.ParserRunner.read_message(LsProxy.Protocol.Message, raw_text)
    method_name = LsProxy.Protocol.Message.method(message)

    %__MODULE__{
      id: System.unique_integer([:positive, :monotonic]),
      lsp_id: lsp_id(message.content),
      error: error(message),
      message: message,
      direction: direction,
      timestamp: now,
      extra_info: LsProxy.Methods.extra_info(method_name, message)
    }
  end

  # Not all messages have id's (e.g. Notification Messages)
  # https://microsoft.github.io/language-server-protocol/specification#notification-message
  defp lsp_id(%{"id" => id}), do: id
  defp lsp_id(_), do: nil

  @doc """
  Returns the method name, or nil if it doesn't exist
  """
  def method(nil), do: nil

  def method(%__MODULE__{} = message_record) do
    %__MODULE__{message: %LsProxy.Protocol.Message{} = message} = message_record
    LsProxy.Protocol.Message.method(message)
  end

  @doc """
  The text that should be used to filter/search on
  """
  def filter_text(%__MODULE__{} = message_record) do
    case method(message_record) do
      nil ->
        ""

      "window/logMessage" ->
        "window/logMessage #{message_record.message.content["params"]["message"]}"

      method ->
        method
    end
  end

  def error(message) do
    case message.content do
      %{"error" => error_map} ->
        {:ok, error} = LsProxy.ResponseError.new(error_map)
        error

      _ ->
        nil
    end
  end
end
