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
  def handle_call({:next, "restart"}, _from, _) do
    {:reply, [{:text,  "restart the coversation"}], [] }
  end

  def handle_call({:next, message}, _from, state) do
    case state do
      [] -> {:reply,
            [ { :text, "Hey, nice to talk to you. I hope I can help you with your property journey. I'd like to ask some information so that I can give you appropriate advice"},
              { :choice, "what's the purpose of the property?", [{"invest", "investment"}, {"residential", "owner occupy"}]}
            ],
            [:init]}
      [:init] -> {:reply, 
          [{:text, "ok, so you want to #{message}"}], [:purpose] }
      _ -> {:reply, [{:text,  "thank you, finished"}], [:purpose] }
    end
  end
end