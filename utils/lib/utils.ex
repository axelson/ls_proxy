defmodule Utils do
  @moduledoc """
  Documentation for Utils.
  """

  def tap(input, fun) when is_function(fun, 1) do
    fun.(input)
    input
  end

  def truncate(string, length, fill \\ "…") when is_binary(string) and is_number(length) do
    if String.length(string) < length do
      string
    else
      {string, _} = String.split_at(string, length)
      string <> fill
    end
  end
end
