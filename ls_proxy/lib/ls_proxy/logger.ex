defmodule LsProxy.Logger do
  def info(message) do
    if Application.fetch_env!(:ls_proxy, :logging_enabled) do
      # IO.puts(message)
      File.write(log_file(), [message, "\n"], [:append])
    end
  end

  defp log_file do
    "/tmp/ls_proxy.log"
  end
end
