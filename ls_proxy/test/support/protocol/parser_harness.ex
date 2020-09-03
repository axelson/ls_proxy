defmodule LsProxyTest.Protocol.ParserHarness do
  def read_message(module, text, input \\ nil) do
    {:ok, string_device} = StringIO.open(text)
    LsProxy.ParserRunner.read_message(module, string_device, :init, input)
  end
end
