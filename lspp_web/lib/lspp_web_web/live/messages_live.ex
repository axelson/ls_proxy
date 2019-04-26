defmodule LsppWebWeb.MessagesLive do
  use Phoenix.LiveView

  def render(assigns) do
    LsppWeb.MessagesView.render("messages.html", assigns)
  end

  def mount(_session, socket) do
    if connected?(socket) do
      LsProxy.ProxyState.register_listener()
    end

    socket =
      socket
      |> assign(:incoming, [])
      |> assign(:outgoing, [])

    {:ok, update_messages(socket)}
  end

  def handle_info({:update_messages}, socket) do
    {:noreply, update_messages(socket)}
  end

  def handle_event("reset", _, socket) do
    LsProxy.ProxyState.clear()
    {:noreply, socket}
  end

  defp update_messages(socket) do
    messages = LsProxy.ProxyState.messages()
    incoming = messages.incoming |> Enum.map(&parse_message(&1.raw_text))
    outgoing = messages.outgoing |> Enum.map(&parse_message(&1.raw_text))

    socket
    |> update(:incoming, fn _ -> incoming end)
    |> update(:outgoing, fn _ -> outgoing end)
  end

  # defp parse_message(message_text), do: message_text
  @spec parse_message(String.t()) :: LsProxy.Protocol.Message.t() | String.t()
  defp parse_message(message_text) do
    IO.inspect(message_text, label: "message_text")
    {:ok, pid} = StringIO.open(message_text)
    {:ok, message} = LsProxy.ParserRunner.read_message(LsProxy.Protocol.Message, pid)
    StringIO.close(pid)
    message
  rescue
    e ->
      message_text
  end
end
