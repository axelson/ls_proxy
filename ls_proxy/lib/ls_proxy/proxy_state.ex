defmodule LsProxy.ProxyState do
  @moduledoc """
  Records the state of LSP session
  """
  use GenServer

  defmodule State do
    defstruct [:pending_outgoing_message, :incoming_messages, :outgoing_messages]
  end

  def start_link(_, name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  @impl GenServer
  def init(_) do
    initial_state = %State{
      pending_outgoing_message: nil,
      incoming_messages: :queue.new(),
      outgoing_messages: :queue.new()
    }

    {:ok, initial_state}
  end

  def register_listener() do
    Registry.register(LsProxy.MessageRegistry, "listener", :value)
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

  def clear(name \\ __MODULE__) do
    GenServer.call(name, {:clear})
  end

  @impl GenServer
  def handle_call({:record_incoming, msg}, _from, state) do
    message = LsProxy.Message.new(msg, :incoming)
    queue = state.incoming_messages
    state = %State{state | incoming_messages: :queue.in(message, queue)}
    {:reply, :ok, state, {:continue, :notify_listeners}}
  end

  def handle_call({:record_outgoing, msg}, _from, state) do
    %State{pending_outgoing_message: pending_message} = state

    # msg =
    #   case pending_message do
    #     nil -> msg
    #     pending_message -> pending_message <> msg
    #   end

    # {:ok, pid} = StringIO.open(msg)

    # # How does the parser runner work when the message is incomplete?
    # case LsProxy.ParserRunner.read_message(Protocol.Message, pid) do
    #   {:ok, message} ->
    #     IO.puts "Got complete message! #{inspect message}"
    #   other ->
    #     IO.inspect(other, label: "got error other")
    # end

    message = LsProxy.Message.new(msg, :outgoing)
    queue = state.outgoing_messages
    state = %State{state | outgoing_messages: :queue.in(message, queue)}
    {:reply, :ok, state, {:continue, :notify_listeners}}
  end

  def handle_call({:messages}, _from, state) do
    messages = %{
      incoming: :queue.to_list(state.incoming_messages),
      outgoing: :queue.to_list(state.outgoing_messages)
    }

    {:reply, messages, state}
  end

  def handle_call({:clear}, _from, _state) do
    state = %State{
      incoming_messages: :queue.new(),
      outgoing_messages: :queue.new()
    }

    {:reply, :ok, state, {:continue, :notify_listeners}}
  end

  @impl GenServer
  def handle_continue(:notify_listeners, state) do
    notify_listeners()
    {:noreply, state}
  end

  def notify_listeners do
    Registry.dispatch(LsProxy.MessageRegistry, "listener", fn entries ->
      for {pid, _value} <- entries do
        send(pid, {:update_messages})
      end
    end)
  end

  def kill_listeners do
    Registry.dispatch(LsProxy.MessageRegistry, "listener", fn entries ->
      for {pid, _value} <- entries do
        Process.exit(pid, :kill)
      end
    end)
  end
end
