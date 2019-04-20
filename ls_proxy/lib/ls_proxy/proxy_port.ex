defmodule LsProxy.ProxyPort do
  @moduledoc """
  Proxy for Port IO operations.
  """

  use GenServer
  require Logger

  defmodule State do
    defstruct [:pid, :os_pid]
  end

  def send_message(msg) do
    GenServer.call(__MODULE__, {:send_message, msg})
  end

  def start_link(_, name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  @impl true
  def init(_) do
    # LsProxy.Logger.info("ProxyPort starting!")
    cmd = LsProxy.Config.language_server_script_path() |> to_charlist()

    {:ok, pid, os_pid} = :exec.run(cmd, [:stdout, :stderr, :stdin, :monitor])

    initial_state = %State{pid: pid, os_pid: os_pid}

    # LsProxy.Logger.info("ProxyPort initial state: #{inspect initial_state}")
    {:ok, initial_state}
  end

  @impl true
  def handle_info({:stdout, _, msg}, state) do
    LsProxy.Logger.info("Got message:\n#{msg}")

    # Send the output we just received from the LSP Server back to the client
    # via our own stdout
    # NOTE: Don't use IO.puts because it adds trailing newlines and newlines are
    # significant in the LSP
    # TODO: Rename stdin and send this output to somewhere else for a cleaner
    # architecture
    IO.write(msg)
    LsProxy.ProxyState.record_outgoing(msg)
    LsProxy.MessageHTTPForwarder.send_to_server(msg, "outgoing")

    {:noreply, state}
  end

  @impl true
  def handle_call({:send_message, msg}, _from, %State{os_pid: os_pid} = state) do
    # TODO: Do we really need to trim this here?
    msg = String.trim_trailing(msg)
    LsProxy.Logger.info("Send Message:\n#{msg}")
    result = :exec.send(os_pid, msg)
    LsProxy.ProxyState.record_incoming(msg)
    LsProxy.MessageHTTPForwarder.send_to_server(msg, "incoming")

    {:reply, result, state}
  end
end
