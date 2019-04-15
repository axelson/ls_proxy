defmodule LsProxy.Logger do
  def info(message) do
    # IO.puts(message)
    File.write(log_file(), [message, "\n"], [:append])
  end

  defp log_file do
    "/tmp/ls_proxy.log"
  end
end
