alias Advisor.Fsm

defmodule Advisor.Worker do
  use GenServer

  ###CLIENT API###
  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{step: :start}, name: __MODULE__)
  end

  def next(message) do
      GenServer.call(__MODULE__, {:next, message})
  end

  ###SERVER API
  def init(%{step: :start}) do
    {:ok, %{step: :start}}
  end

  def handle_call({:next, message}, _from, state) do
    {reply, next_state} = Fsm.next(state, message)
    {:reply, reply, next_state}
  end
end