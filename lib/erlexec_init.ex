defmodule ErlexecInit do
  @moduledoc """
  Responsible for starting Erlexec in a manner compatible with escripts. By
  default the exec-port binary is compiled into erlexec's priv folder, but since
  escripts don't have access to the priv directories we need to store the binary
  into the code and then on startup we need to write it out into the system's
  tempdirectory

  Reference: https://elixirforum.com/t/unable-to-run-erlexec-in-a-escript/21603
  """

  use GenServer

  @exec_port_binary_path Application.app_dir(:erlexec, [
                           "priv",
                           :erlang.system_info(:system_architecture),
                           "exec-port"
                         ])

  @execport_binary File.read!(@exec_port_binary_path)

  def start_link(_, name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  @impl GenServer
  def init(_) do
    port_exe_path =
      System.tmp_dir!()
      |> Path.join("tmp-exec-port-#{:rand.uniform(1000)}")
      |> String.to_charlist()

    File.write!(port_exe_path, @execport_binary)
    File.chmod!(port_exe_path, 0o700)

    :exec.start(portexe: port_exe_path)

    {:ok, []}
  end
end
