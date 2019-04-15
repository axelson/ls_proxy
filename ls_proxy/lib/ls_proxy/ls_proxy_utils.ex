defmodule LsProxy.LsProxyUtils do
  def collect_successes(list) do
    Enum.reduce(list, {:ok, []}, fn
      {:ok, item}, {:ok, list} ->
        {:ok, [item | list]}

      {:ok, _}, {:error, _} = err ->
        err

      {:error, error}, {:ok, _} ->
        {:error, [error]}

      {:error, error}, {:error, errors} ->
        {:error, [error | errors]}
    end)
  end
end
