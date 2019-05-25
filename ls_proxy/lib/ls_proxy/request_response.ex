defmodule LsProxy.RequestResponse do
  @moduledoc """
  Contains references to a request and response %LsProxy.MessageRecord{}
  """

  @type t :: %__MODULE__{
          id: integer,
          request: LsProxy.MessageRecord.t(),
          response: LsProxy.MessageRecord.t()
        }

  defstruct [:id, :request, :response]

  @doc """
  Create a new RequestResponse from a %LsProxy.MessageRecord{}
  """
  def new(%LsProxy.MessageRecord{lsp_id: nil}), do: {:error, :no_id}

  def new(%LsProxy.MessageRecord{direction: :incoming, lsp_id: id} = message_record) do
    {:ok, %__MODULE__{request: message_record, id: id}}
  end

  def new(%LsProxy.MessageRecord{direction: :outgoing, lsp_id: id} = message_record) do
    {:ok, %__MODULE__{response: message_record, id: id}}
  end

  def add(
        %__MODULE__{request: nil, id: id} = req_resp,
        %LsProxy.MessageRecord{direction: :incoming, lsp_id: id} = message_record
      ) do
    {:ok, %__MODULE__{req_resp | request: message_record}}
  end

  def add(
    %__MODULE__{response: nil, id: id} = req_resp,
    %LsProxy.MessageRecord{direction: :outgoing, lsp_id: id} = message_record
  ) do
    {:ok, %__MODULE__{req_resp | response: message_record}}
  end
end
