defmodule LsProxy.ErrorCodesParserTest do
  use ExUnit.Case, async: true

  doctest LsProxy.ErrorCodesParser

  test "to_tuple/1" do
    str = "export const RequestCancelled: number = -32800;"
    assert LsProxy.ErrorCodesParser.to_tuple(str) == {"RequestCancelled", -32800}
  end

  test "run" do
    file_contents = """
    export namespace ErrorCodes {
      // Defined by JSON RPC
      export const ParseError: number = -32700;
      export const UnknownErrorCode: number = -32001;

      // Defined by the protocol.
      export const ContentModified: number = -32801;
    }

    """

    map = LsProxy.ErrorCodesParser.build_map(file_contents)

    assert map == %{
             "ContentModified" => -32801,
             "ParseError" => -32700,
             "UnknownErrorCode" => -32001
           }
  end
end
