defmodule LsProxy.Config do
  def language_server_script_path do
    to = Application.get_env(:ls_proxy, :proxy_to, :elixir_ls)
    LsProxy.Logger.info ["proxy_to: ", to]
    case Application.get_env(:ls_proxy, :proxy_to, :elixir_ls) do
      :elixir_ls -> "/home/jason/dev/forks/elixir-ls/release/language_server.sh"
      :ls_proxy -> "/home/jason/dev/ls_proxy/ls_proxy"
      :echo_script -> "/home/jason/dev/ls_proxy/echo_script.bash"
    end
  end
end
