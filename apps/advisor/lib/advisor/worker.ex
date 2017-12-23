defmodule Advisor.Worker do
  use GenServer

  ###CLIENT API###
  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def next(message) do
      GenServer.call(__MODULE__, {:next, message})
  end

  ###SERVER API
  def handle_call({:next, message}, _from, _state) do
    {:reply, "You have said #{message}", []}
  end
end