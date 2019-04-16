defmodule LsProxy.ProxyState do
  @moduledoc """
  Records the state of LSP session
  """
  use GenServer

  defmodule State do
    defstruct [:incoming_messages, :outgoing_messages]
  end

  def start_link(_, name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  @impl GenServer
  def init(_) do
    initial_state = %State{
      incoming_messages: :queue.new(),
      outgoing_messages: :queue.new()
    }

    {:ok, initial_state}
  end

  def record_incoming(msg, name \\ __MODULE__) do
    GenServer.call(name, {:record_incoming, msg})
  end

  def record_outgoing(msg, name \\ __MODULE__) do
    GenServer.call(name, {:record_outgoing, msg})
  end

  def messages(name \\ __MODULE__) do
    GenServer.call(name, {:messages})
  end

  @impl GenServer
  def handle_call({:record_incoming, msg}, _from, state) do
    queue = state.incoming_messages
    state = %{state | incoming_messages: :queue.in(msg, queue)}
    {:reply, :ok, state}
  end

  def handle_call({:record_outgoing, msg}, _from, state) do
    queue = state.outgoing_messages
    state = %{state | outgoing_messages: :queue.in(msg, queue)}
    {:reply, :ok, state}
  end

  def handle_call({:messages}, _from, state) do
    messages = %{
      incoming: :queue.to_list(state.incoming_messages),
      outgoing: :queue.to_list(state.outgoing_messages)
    }

    {:reply, messages, state}
  end
end
