defmodule LsppWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :lspp_web,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {LsppWeb.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # {:contex, path: "~/dev/forks/contex"},
      {:contex, git: "https://github.com/mindok/contex"},
      {:phoenix, "~> 1.4.3"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_view, "~> 0.4.1"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:earmark, "~> 1.3"},
      {:ls_proxy, path: "../ls_proxy"},
      {:utils, path: "../utils"},
      # {:exsync, github: "falood/exsync", ref: "master", only: :dev},
      {:exsync, path: "~/dev/forks/exsync", only: :dev},
      {:phoenix_live_reload, "~> 1.2", only: :dev}
    ]
  end
end
