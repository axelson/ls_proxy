defmodule LsProxy.Config do
  def language_server_script_path do
    case Application.fetch_env!(:ls_proxy, :proxy_to) do
      "elixir_ls" -> "/home/jason/dev/forks/elixir-ls/release/language_server.sh"
      "ls_proxy" -> "/home/jason/dev/ls_proxy/ls_proxy"
      "echo_script" -> "/home/jason/dev/ls_proxy/echo_script.bash"
    end
  end
end
