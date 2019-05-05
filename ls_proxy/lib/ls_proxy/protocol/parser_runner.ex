defmodule LsProxy.ParserRunner do
  def read_message(module, device_or_string \\ :stdio)

  def read_message(module, string) when is_binary(string) do
    {:ok, pid} = StringIO.open(string)
    result = read_message(module, pid)
    StringIO.close(pid)
    result
  end

  def read_message(module, device) do
    read_message(module, device, :init, nil)
    |> Utils.tap(fn
      {:ok, _} -> nil
      {:error, message} -> LsProxy.Logger.info("Error reading message: #{inspect message}")
    end)
  end

  def read_message(module, device, state, result) do
    case module.read(state, result) do
      {:ok, :done, result} ->
        {:ok, result}

      {:ok, state, command} ->
        case handle_parser_command(command, device) do
          {:ok, input} -> read_message(module, device, state, input)
          {:error, message} -> {:error, message}
        end

      {:error, message} ->
        {:error, message}
    end
  end

  @spec handle_parser_command(Protocol.Parser.command(), any) :: any
  defp handle_parser_command(:read_line, device) do
    {:ok, IO.read(device, :line)}
  end

  defp handle_parser_command({:read_bytes, bytes}, device) do
    case IO.read(device, bytes) do
      string when byte_size(string) == bytes ->
        # LsProxy.Logger.info "Successfully read #{bytes}"
        # LsProxy.Logger.info "From: #{inspect string}"
        {:ok, string}

      string ->
        additional_bytes = bytes - byte_size(string)
        case IO.read(device, additional_bytes) do
          :eof -> {:error, "not_enough_input. Wanted #{bytes}. Got: #{byte_size(string)}"}
          additional_string when byte_size(additional_bytes) -> {:ok, string <> additional_string}
        end
    end
  end
end
