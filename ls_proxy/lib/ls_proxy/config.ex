defmodule LsProxy.Config do
  def language_server_script_path do
    case Application.fetch_env!(:ls_proxy, :proxy_to) do
      "elixir_ls" ->
        # In-repo ElixirLS
        Path.join(__DIR__, "../../../elixir-ls/release/language_server.sh") |> Path.expand()

      "elixir_ls_dev" ->
        Path.join(System.user_home!(), "dev/forks/elixir-ls/release/language_server.sh")
        |> Path.expand()

      "rls" ->
        "/home/jason/.asdf/shims/rls"

      "ls_proxy" ->
        Path.join(System.user_home!(), "dev/ls_proxy/ls_proxy") |> Path.expand()
    end
  end
end
