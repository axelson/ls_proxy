defmodule LsppWebWeb.MessagesLive do
  use Phoenix.LiveView

  def render(assigns) do
    LsppWeb.MessagesView.render("messages.html", assigns)
  end

  def mount(_session, socket) do
    if connected?(socket) do
      LsProxy.ProxyState.register_listener()
    end

    socket = assign(socket, :messages, [])

    {:ok, update_messages(socket)}
  end

  def handle_info({:update_messages}, socket) do
    {:noreply, update_messages(socket)}
  end

  defp update_messages(socket) do
    messages = LsProxy.ProxyState.messages()
    update(socket, :messages, fn _ -> messages end)
  end
end
