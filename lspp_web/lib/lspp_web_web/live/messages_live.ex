defmodule LsppWebWeb.MessagesLive do
  use Phoenix.LiveView

  def render(assigns) do
    IO.puts "render!"
    ~L"""
    <div>
      messages:
      <pre>
      <%= inspect(@messages, pretty: true) %>
      </pre>
    </div>
    """
  end

  def mount(_session, socket) do
    IO.puts "Mounting!"
    if connected?(socket), do: IO.puts "CONNECTED!"
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

    socket = assign(socket, :messages, [])

    {:ok, update_messages(socket)}
  end

  def handle_info(:tick, socket) do
    IO.puts "tick!"
    {:noreply, update_messages(socket)}
  end

  defp update_messages(socket) do
    messages = LsProxy.ProxyState.messages()
    update(socket, :messages, fn _ -> messages end)
  end
end
