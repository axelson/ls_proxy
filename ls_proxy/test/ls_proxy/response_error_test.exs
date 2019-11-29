defmodule LsProxy.ResponseErrorTest do
  use ExUnit.Case, async: true

  doctest LsProxy.ResponseError

  test "new/1" do
    map = %{"code" => -32800, "message" => "Request cancelled"}
    LsProxy.ResponseError.new(map)
  end
end
