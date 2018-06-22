defmodule Collector.Async do
  def async_send(data, message) do
    caller = self()
    spawn(fn ->
      send(caller, {:result, message.(data)})
    end)
  end

  def collect do
    receive do
      {:result, result} -> result
    end
  end
end
