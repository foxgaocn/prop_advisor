defmodule Advisor.Fsm do
  @retry  [ 
    {:choice, "Sorry, I don't quite understand what you said, do you want to", [{"restart the conversation", "restart"}, {"answer the question again", "back"}]}
  ]

  #:restart -> :purpose
  def next(_, "restart") do
    next_question = [
      {:text,  "resetting everything and let's restart"},
      { :choice, "what's the purpose of the property?", [{"invest", "inv"}, {"owner occupy", "resi"}]}  
    ]

    {next_question, %{step: :purpose}}
  end

  #:start -> :purpose
  def next(%{step: :start}, _) do
    next_question = [ 
        { :text, "Hey, nice to talk to you. I hope I can help you with your property journey. I'd like to ask some information so that I can give you appropriate advice"},
        { :choice, "what's the purpose of the property?", [{"invest", "inv"}, {"owner occupy", "resi"}]}
      ]
    
    {next_question, %{step: :purpose}}
  end

  #:greeting -> :purpose
  def next(%{step: :greeting}, _) do
    next_question = [
      { :choice, "what's the purpose of the property?", [{"invest", "inv"}, {"owner occupy", "resi"}]}
    ]
    {next_question, %{step: :purpose}}
  end

  # :purpose -> :province
  def next(%{step: :purpose} = state, message) do
    next_question = [ {:choice, "which state are you looking", 
      [ {"NSW", "nsw"}, 
        {"VIC", "vic"},
        {"QLD", "qld"},
        {"SA", "sa"},
        {"WA", "wa"},
        {"NT", "nt"},
        {"TAS", "tas"},
      ]}]
    
    case message do
      "resi" -> { next_question, %{step: :province, purpose: "resi"} }
      "inv" -> { next_question, %{step: :province, purpose: "inv"} }
      "back" -> next(%{step: :greeting}, "_")
      _ -> { @retry, state }
    end
  end

  # :province -> :budget
  def next(%{step: :province} = state, message) do
      next_question = [ {:choice, "what's your budget", 
      [
        {"around $200k", "200"}, 
        {"around $400k", "400"},
        {"around $600k", "600"},
        {"around $800k", "800"},
        {"around $1M", "1000"},
        {"around $1.2M", "1200"},
        {"around $1.4M", "1400"},
        {"around $1.7M", "1700"},
        {"around $2M", "2000"},
        {"around $2.5M", "2500"},
        {"above $3M", "3000"},
      ]}]
    
    cond do
      Enum.member?(["nsw", "vic", "nt", "tas", "sa", "wa"], message) -> { next_question, Map.merge(state, %{step: :budget, state: message})}
      message == "back" -> next(Map.put(state, :step, :purpose), Map.get(state, :purpose))
      true -> { @retry, state }
    end
  end

  # :budget -> :finish
  def next(%{step: :budget} = state, message) do
    next_question = [ {:text, "thank you"} ]
    if (message == "back") do
      next(Map.put(state, :step, :province), Map.get(state, :state))
    else
      case Integer.parse(message) do
        :error -> { @retry, state }
        {budget, _} -> { next_question, Map.merge(state, %{budget: budget, step: :finish})}
      end
    end
  end

  # :finish -> :finish
  def next(%{step: :finish} = state, _) do
    next_question = [ {:text, "thank you"} ]
    {next_question, state}
  end
  
end