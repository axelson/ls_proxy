defmodule LsppWebWeb.LogTabComponent do
  use Phoenix.LiveComponent
  alias LsProxy.MessageRecord

  def logs(message_records) do
    message_records
    |> Enum.filter(fn message_record ->
      MessageRecord.method(message_record) == "window/logMessage"
    end)
  end
end
