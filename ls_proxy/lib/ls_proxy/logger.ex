defmodule LsProxy.Logger do
  def info(message), do: log_to(log_file(), [message, "\n"])

  defp log_to(file, message) do
    if Application.fetch_env!(:ls_proxy, :logging_enabled) do
      # IO.puts(message)
      File.write(file, [message], [:append])
    end
  end

  defp log_file do
    "/tmp/ls_proxy.log"
  end

  def log_in(message), do: log_to("/tmp/ls_proxy_in.log", [message])
  def log_out(message), do: log_to("/tmp/ls_proxy_out.log", [message])
end
