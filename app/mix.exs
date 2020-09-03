defmodule App.MixProject do
  use Mix.Project

  def project do
    [
      app: :app,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {App.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:exsync, github: "falood/exsync", ref: "master", only: :dev},
      {:ls_proxy, path: "../ls_proxy"},
      {:lspp_web, path: "../lspp_web"}
    ]
  end

  defp escript do
    [
      main_module: LsProxy.CLI
      # Needed to enable epmd to start automatically
      # emu_args: "-sname proxy"
    ]
  end
end
