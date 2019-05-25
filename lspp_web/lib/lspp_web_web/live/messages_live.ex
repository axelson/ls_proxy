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
      |> assign(:formatted, %{})
      |> assign(:outstanding, %{})

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

  def handle_event("expand-formatted:" <> id, _, socket) do
    id = String.to_integer(id)
    %{formatted: formatted} = socket.assigns
    formatted = Map.put(formatted, id, true)

    socket =
      socket
      |> assign(:formatted, formatted)

    {:noreply, socket}
  end

  def handle_event("collapse-formatted:" <> id, _, socket) do
    id = String.to_integer(id)
    %{formatted: formatted} = socket.assigns
    formatted = Map.put(formatted, id, false)

    socket =
      socket
      |> assign(:formatted, formatted)

    {:noreply, socket}
  end

  defp update_messages(socket) do
    socket
    |> update(:message_records, fn _ ->
      LsProxy.ProxyState.messages()
      |> Enum.reverse()
    end)
    |> update_outstanding()
  end

  defp update_outstanding(socket) do
    %{message_records: message_records} = socket.assigns
    outstanding = process(message_records)
    |> Enum.sort_by(fn {id, _} -> id end)
    |> Enum.reverse()
    |> Enum.map(fn {_id, req_resp} -> req_resp end)

    socket
    |> assign(:outstanding, outstanding)
  end

  defp process(message_records) do
    message_records
    |> Enum.reduce(%{}, fn
      %{lsp_id: nil}, outstanding ->
        outstanding

      %{lsp_id: lsp_id} = message_record, outstanding ->
        {:ok, initial} = LsProxy.RequestResponse.new(message_record)

        Map.update(outstanding, lsp_id, initial, fn existing ->
          {:ok, req_resp} = LsProxy.RequestResponse.add(existing, message_record)
          req_resp
        end)
    end)
  end
end
