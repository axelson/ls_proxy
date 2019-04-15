defmodule LsProxy.ParserRunner do
  def read_message(module, device \\ :stdio) do
    read_message(module, device, :init, nil)
  end

  def read_message(module, device, state, result) do
    case module.read(state, result) do
      {:ok, :done, result} ->
        {:ok, result}

      {:ok, state, command} ->
        input = handle_parser_command(command, device)
        read_message(module, device, state, input)

      {:error, message} ->
        {:error, message}
    end
  end

  @spec handle_parser_command(Protocol.Parser.command(), any) :: any
  defp handle_parser_command(:read_line, device) do
    IO.read(device, :line)
  end

  defp handle_parser_command({:read_bytes, bytes}, device) do
    IO.read(device, bytes)
  end
end
