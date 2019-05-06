defmodule LsProxy.ProxyPort do
  @moduledoc """
  GenServer that handles communication with the language_server process via stdin/stdout. Is linked to the Port.
  """

  use GenServer
  require Logger

  defmodule State do
    defstruct [:pid, :os_pid, :partial_message]
  end

  def send_message(msg) do
    GenServer.call(__MODULE__, {:send_message, msg})
  end

  def start_link(_, name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  @impl GenServer
  def init(_) do
    # LsProxy.Logger.info("ProxyPort starting!")
    cmd = LsProxy.Config.language_server_script_path() |> to_charlist()

    {:ok, pid, os_pid} = :exec.run(cmd, [:stdout, :stderr, :stdin, :monitor])

    initial_state = %State{pid: pid, os_pid: os_pid, partial_message: ""}

    # LsProxy.Logger.info("ProxyPort initial state: #{inspect initial_state}")
    {:ok, initial_state}
  end

  def read_message(msg) when is_binary(msg) do
    {:ok, string_io} = StringIO.open(msg)

    LsProxy.ParserRunner.read_message(LsProxy.Protocol.Message, string_io)
    |> Utils.tap(fn _ -> StringIO.close(string_io) end)
  end

  def handle_successful_message(message) do
    msg = LsProxy.Protocol.Message.to_string(message)
    # LsProxy.Logger.info("parsed outgoing string: #{inspect msg}")
    LsProxy.Logger.info("LS->Editor: #{msg}")
    # LsProxy.Logger.info("Sending outgoing message")
    IO.write(:stdio, msg)
    # IO.puts(msg)
    LsProxy.Logger.log_out(msg)
    LsProxy.ProxyState.record_outgoing(msg)
    LsProxy.MessageHTTPForwarder.send_to_server(msg, "outgoing")

    :ok
  end

  # Language Server -> LsProxy -> LsProxyUpstream
  #                            -> LsProxyLog
  #                            -> Editor (stdout)
  @impl GenServer
  def handle_info({:stdout, _, msg}, %State{partial_message: partial_message} = state) do
    msg = partial_message <> msg

    case read_message(msg) do
      {:ok, message} ->
        handle_successful_message(message)
        {:noreply, %State{state | partial_message: ""}}

      {:error, {:incomplete_message, _}} ->
        {:noreply, %State{state | partial_message: msg}}
    end
  end
    {:noreply, state}
  end

  @impl true
  def handle_call({:send_message, msg}, _from, %State{os_pid: os_pid} = state) do
    # TODO: Do we really need to trim this here?
    msg = String.trim_trailing(msg)
    LsProxy.Logger.info("Send Message:\n#{msg}")
    LsProxy.Logger.log_in(msg)
    result = :exec.send(os_pid, msg)
    LsProxy.ProxyState.record_incoming(msg)
    LsProxy.MessageHTTPForwarder.send_to_server(msg, "incoming")

    {:reply, result, state}
  end
end
