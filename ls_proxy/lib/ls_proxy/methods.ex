defmodule LsProxy.Methods do
  @methods %{
    "textDocument/hover" => LsProxy.Methods.TextDocumentHoverMethod,
    "textDocument/completion" => LsProxy.Methods.TextDocumentCompletionMethod
  }

  @callback extra_info(any) :: String.t()

  def extra_info(method_name, request) do
    case @methods[method_name] do
      nil -> {:error, {:method_not_found, method_name}}
      method -> method.extra_info(request)
    end
  end
end
