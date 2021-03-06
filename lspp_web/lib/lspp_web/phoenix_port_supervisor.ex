defmodule LsppWeb.PhoenixPortSupervisor do
  @moduledoc """
  Starts up Phoenix, but controls the port with application configuration,
  increments the port until Phoenix starts up successfully.
  """
  use GenServer

  def start_link(_, name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, nil, name: name)
  end

  def init(_) do
    initial_port = initial_port()

    start_phoenix(initial_port, initial_port)
    |> Utils.tap(fn
      {:ok, port} -> lsp_log_message("LsProxy web running on port #{port}")
      _ -> nil
    end)
  end

  defp start_phoenix(initial_port, port) when port - initial_port < 15 do
    set_port(port)

    DynamicSupervisor.start_child(LsppWeb.DynamicSupervisor, LsppWebWeb.Endpoint)
    |> interpret_results()
    |> case do
      {:ok, _} -> {:ok, port}
      {:error, :eaddrinuse} -> start_phoenix(initial_port, port + 1)
    end
  end

  defp start_phoenix(_, _) do
    {:error, :ports_exhausted}
  end

  def get_port, do: Application.get_env(:lspp_web, :phoenix_port)

  defp set_port(port) do
    Application.put_env(:lspp_web, :phoenix_port, port)
  end

  defp interpret_results({:ok, pid}), do: {:ok, pid}

  defp interpret_results({:error, error}) do
    case error do
      {:shutdown,
       {:failed_to_start_child, {:ranch_listener_sup, LsppWebWeb.Endpoint.HTTP},
        {:shutdown,
         {:failed_to_start_child, :ranch_acceptors_sup,
          {:listen_error, LsppWebWeb.Endpoint.HTTP, :eaddrinuse}}}}} ->
        {:error, :eaddrinuse}
    end
  end

  defp initial_port do
    cond do
      port = System.get_env("PORT") ->
        String.to_integer(port)

      config = Application.get_env(:lspp_web, LsppWebWeb.Endpoint) ->
        get_in(config, [:http, :port])

      true ->
        raise "Port not set"
    end
  end

  # TODO: This should only print out if we're actually running in proxy mode
  # instead of standalone mode
  defp lsp_log_message(text) do
    message =
      LsProxy.Protocol.Messages.WindowLogMessage.build(text)
      |> LsProxy.Protocol.JsonRPC.Protocol.to_rpc_message()

    IO.write(:stdio, message)
  end
end
