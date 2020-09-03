defmodule LsProxy.ErrorCodesTest do
  use ExUnit.Case, async: true

  doctest LsProxy.ErrorCodes

  test "error_name/1" do
    assert LsProxy.ErrorCodes.error_name(-32602) == {:ok, "InvalidParams"}
    assert LsProxy.ErrorCodes.error_name(-32700) == {:ok, "ParseError"}
    assert LsProxy.ErrorCodes.error_name(nil) == {:error, :no_error_code_provided}
    assert LsProxy.ErrorCodes.error_name(9999) == {:error, :invalid_error_code}
  end
end
