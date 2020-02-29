defmodule LsppWeb.RequestView do
  use LsppWebWeb, :view

  @checkmark "✔"

  @spec render_request(LsProxy.RequestResponse.t()) :: any
  def render_request(%LsProxy.RequestResponse{} = request) do
    method_name = LsProxy.MessageRecord.method(request.request)
    do_render_request(method_name, request)
  end

  def do_render_request("initialize", request) do
    capabilities = request.response.message.content["result"]["capabilities"]

    case validate_initialize_response(request.response) do
      :ok -> @checkmark
      {:error, message} -> "Error: #{message}"
    end
  end

  def do_render_request(_, _request) do
    @checkmark
  end

  defp validate_initialize_response(%LsProxy.MessageRecord{} = response) do
    capabilities = response.message.content["result"]["capabilities"]

    LsProxy.Requests.Initialize.validate_capabilities(capabilities)
  end
end
