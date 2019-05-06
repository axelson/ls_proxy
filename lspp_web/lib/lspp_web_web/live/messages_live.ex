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
      |> assign(:message_records, [])
      |> assign(:expanded, %{})

    {:ok, update_messages(socket)}
  end

  def handle_info({:update_messages}, socket) do
    {:noreply, update_messages(socket)}
  end

  def handle_event("reset", _, socket) do
    LsProxy.ProxyState.clear()
    {:noreply, socket}
  end

  def handle_event("expand:" <> id, _, socket) do
    id = String.to_integer(id)
    %{expanded: expanded} = socket.assigns
    expanded = Map.put(expanded, id, true)

    socket =
      socket
      |> assign(:expanded, expanded)

    {:noreply, socket}
  end

  def handle_event("collapse:" <> id, _, socket) do
    id = String.to_integer(id)
    %{expanded: expanded} = socket.assigns
    expanded = Map.put(expanded, id, false)

    socket =
      socket
      |> assign(:expanded, expanded)

    {:noreply, socket}
  end

  defp update_messages(socket) do
    socket
    |> update(:message_records, fn _ -> LsProxy.ProxyState.messages() end)
  end
end
