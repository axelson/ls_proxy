defmodule LsProxy.MessageHTTPForwarder do
  def send_to_server(raw_message, direction) do
    # LsProxy.Logger.info(inspect(proxy_to(), label: "proxy_to()"))

    if proxy_to() do
      headers = [{"Content-Type", "application/json"}]
      payload = Jason.encode!(%{message: raw_message, direction: direction})
      Task.start(fn ->
        result = Mojito.request(:post, proxy_to(), headers, payload)
        # LsProxy.Logger.info(inspect(result, label: "result"))
        result
      end)
    end
  end

  defp proxy_to, do: Application.get_env(:ls_proxy, :http_proxy_to)
end
