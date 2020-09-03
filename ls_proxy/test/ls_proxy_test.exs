defmodule LsProxyTest do
  use ExUnit.Case
  doctest LsProxy

  test "greets the world" do
    assert LsProxy.hello() == :world
  end
end
