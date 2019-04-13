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
    GenServer.call(__MODULE__, {:send_message, msg <> "\n"})
  end

  def start_link(_, name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  @impl true
  def init(_) do
    LsProxy.Logger.info("ProxyPort starting!")
    cmd = LsProxy.Config.language_server_script_path() |> to_charlist()

    {:ok, pid, os_pid} = :exec.run(cmd, [:stdout, :stderr, :stdin, :monitor])

    initial_state = %State{pid: pid, os_pid: os_pid}

    LsProxy.Logger.info("ProxyPort initial state: #{inspect initial_state}")
    {:ok, initial_state}
  end

  @impl true
  def handle_info({:stdout, _, msg}, state) do
    LsProxy.Logger.info("Got message: #{inspect msg}")
    {:noreply, state}
  end

  @impl true
  def handle_call({:send_message, msg}, _from, %State{os_pid: os_pid} = state) do
    res = :exec.send(os_pid, msg)
    LsProxy.Logger.info("send_message res: #{inspect res} for message: #{inspect msg} to pid: #{inspect os_pid}")

    {:reply, res, state}
  end
end
