defmodule LsProxy.Config do
  def language_server_script_path do
    case Application.fetch_env!(:ls_proxy, :proxy_to) do
      "elixir_ls" ->
        Path.join(__DIR__, "../../../elixir-ls/release/language_server.sh") |> Path.expand()

      "elixir_ls_dev" ->
        Path.expand("~/dev/forks/elixir-ls/release/language_server.sh")

      "ls_proxy" ->
        "/home/jason/dev/ls_proxy/ls_proxy"
    end
  end
end
