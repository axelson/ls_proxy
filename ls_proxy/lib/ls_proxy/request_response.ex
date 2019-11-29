defmodule LsProxy.RequestResponse do
  @moduledoc """
  Contains references to a request and response %LsProxy.MessageRecord{}
  """

  @type status :: :pending | :complete | :cancelled | :partial
  @type t :: %__MODULE__{
          id: integer,
          request: LsProxy.MessageRecord.t(),
          response: LsProxy.MessageRecord.t(),
          status: status
        }

  defstruct [:id, :request, :response, :status]

  @doc """
  Create a new RequestResponse from a %LsProxy.MessageRecord{}
  """
  def new(%LsProxy.MessageRecord{lsp_id: nil}), do: {:error, :no_id}

  def new(%LsProxy.MessageRecord{direction: :incoming, lsp_id: id} = message_record) do
    {:ok, %__MODULE__{request: message_record, id: id, status: :pending}}
  end

  def new(%LsProxy.MessageRecord{direction: :outgoing, lsp_id: id} = message_record) do
    {:ok, %__MODULE__{response: message_record, id: id, status: :partial}}
  end

  def add(
        %__MODULE__{request: nil, id: id} = req_resp,
        %LsProxy.MessageRecord{direction: :incoming, lsp_id: id} = message_record
      ) do
    status =
      if is_cancel_response(req_resp.response) do
        :canceled
      else
        :complete
      end

    {:ok, %__MODULE__{req_resp | request: message_record, status: status}}
  end

  def add(
        %__MODULE__{response: nil, id: id} = req_resp,
        %LsProxy.MessageRecord{direction: :outgoing, lsp_id: id} = message_record
      ) do
    status =
      if is_cancel_response(message_record) do
        :canceled
      else
        :complete
      end

    {:ok, %__MODULE__{req_resp | response: message_record, status: status}}
  end

  # Ignore additional messages if this is already canceled or complete
  # This could occur due to a race condition
  def add(%__MODULE__{status: :canceled} = req_resp, _), do: {:ok, req_resp}
  def add(%__MODULE__{status: :complete} = req_resp, _), do: {:ok, req_resp}

  defp is_cancel_response(message_record) do
    case message_record.error do
      %{error_name: "RequestCancelled"} -> true
      _ -> false
    end
  end
end
