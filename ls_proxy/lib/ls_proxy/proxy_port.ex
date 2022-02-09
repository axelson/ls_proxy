defmodule LsProxy.ProxyPort do
  @moduledoc """
  GenServer that uses erlexec to launch the LanguageServer process, then
  controls the stdin/stdout of the LanguageServer process.
  """

  use GenServer
  require Logger

  @compiled_elixir_version System.version()
  @compiled_otp_version System.otp_release()

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
    LsProxy.Logger.info("ProxyPort starting!")
    cmd = LsProxy.Config.language_server_script_path() |> to_charlist()

    {:ok, pid, os_pid} = :exec.run(cmd, [:stdout, :stderr, :stdin, :monitor])

    initial_state = %State{pid: pid, os_pid: os_pid, partial_message: ""}

    LsProxy.Logger.info("ProxyPort initial state: #{inspect(initial_state)}")

    log_message("LsProxy starting!")
    log_message("LsProxy Elixir version: #{System.build_info()[:build]}")
    log_message("LsProxy Erlang version: #{System.otp_release()}")

    log_message(
      "LsProxy compiled with Elixir #{@compiled_elixir_version}" <>
        " and erlang #{@compiled_otp_version}"
    )

    log_message("LsProxy connecting to #{LsProxy.Config.language_server_script_path()}")

    {:ok, initial_state}
  end

  def read_message(msg) when is_binary(msg) do
    {:ok, string_io} = StringIO.open(msg)

    LsProxy.ParserRunner.read_message(LsProxy.Protocol.Message, string_io)
    |> Utils.tap(fn _ -> StringIO.close(string_io) end)
  end

  def handle_successful_message(message) do
    LsProxy.Logger.info("LS->Editor: received message: #{inspect(message)}")
    msg = LsProxy.Protocol.Message.to_string(message)
    LsProxy.Logger.info("parsed outgoing string: #{inspect(msg)}")
    LsProxy.Logger.info("LS->Editor sent: #{msg}")
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

  @impl GenServer
  def handle_info({:DOWN, _os_pid, :process, _pid, {:exit_status, exit_status}}, state) do
    LsProxy.Logger.info("Language Server crashed with exit status #{exit_status} :(")
    # TODO: Restart it?
    {:noreply, state}
  end

  def handle_info(msg, state) do
    LsProxy.Logger.info("UNHANDLED HANDLE_INFO: #{inspect(msg)}")
    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:send_message, msg}, _from, %State{os_pid: os_pid} = state) do
    # This trim was previously needed before generating our own content-length heades
    # Without this: elixir-ls is unable to parse the message
    # msg = String.trim_trailing(msg)

    # LsProxy.Logger.info("Editor->LS:\n#{inspect msg}")
    # LsProxy.Logger.info("Editor->LS: message size: #{byte_size(msg)}")
    LsProxy.Logger.log_in(msg)
    result = :exec.send(os_pid, msg)
    # LsProxy.Logger.info("sent message to elixir-ls and got: #{inspect result}")
    LsProxy.ProxyState.record_incoming(msg)
    LsProxy.MessageHTTPForwarder.send_to_server(msg, "incoming")

    {:reply, result, state}
  end

  def log_message(text) do
    message =
      LsProxy.Protocol.Messages.WindowLogMessage.build(text)
      |> LsProxy.Protocol.JsonRPC.Protocol.to_rpc_message()

    IO.write(:stdio, message)
  end
end
