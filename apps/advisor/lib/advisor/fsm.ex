alias Advisor.{Suburb, Questions}

defmodule Advisor.Fsm do
  @retry  [ 
    {:choice, "Sorry, I don't quite understand what you said, do you want to", [{"restart the conversation", "restart"}, {"answer the question again", "back"}]}
  ]

  #:restart -> :purpose
  def next(_, "restart") do
    {Questions.get(:restart), %{step: :purpose}}
  end

  #:start -> :purpose
  def next(%{step: :start}, _) do
    {Questions.get(:start), %{step: :purpose}}
  end

  #:greeting -> :purpose
  def next(%{step: :greeting}, _) do
    {Questions.get(:greeting), %{step: :purpose}}
  end

  # :purpose -> :province
  def next(%{step: :purpose} = state, message) do
    next_question = Questions.get(:purpose)

    case message do
      "resi" -> { next_question, %{step: :province, purpose: "resi"} }
      "inv" -> { next_question, %{step: :province, purpose: "inv"} }
      "back" -> { Questions.get(:greeting), state }
      _ -> { @retry, state }
    end
  end

  # :province -> :budget
  def next(%{step: :province} = state, message) do
    next_question = Questions.get(:province)
    
    cond do
      Enum.member?(["nsw", "vic", "qld", "nt", "tas", "sa", "wa"], message) -> { next_question, Map.merge(state, %{step: :budget, state: message})}
      message == "back" -> {Questions.get(:purpose)}
      true -> { @retry, state }
    end
  end

  # :budget -> :where
  def next(%{step: :budget} = state, message) do
    next_question = Questions.get(:budget)
    if (message == "back") do
      { Questions.get(:province), state }
    else
      case Integer.parse(message) do
        :error -> { @retry, state }
        {budget, _} -> { next_question, Map.merge(state, %{budget: budget, step: :where})}
      end
    end
  end

  # :where -> :suburb | :location
  def next(%{step: :where} = state, message) do
    case message do
      "yes" -> 
        next_question = Questions.get(:suburb_yes)
        next_state = Map.merge(state, %{where: "yes", step: :suburb, previous_step: :where})
        {next_question, next_state}
      "no" ->
        next_question = Questions.get(:suburb_no)
        next_state = Map.merge(state, %{where: "no", step: :location})
        {next_question, next_state}
      "back" -> { Questions.get(:budget), state }
      _ -> { @retry, state }
    end
  end

  # :suburb -> :what
  def next(%{step: :suburb} = state, message) do
    if(message == "back") do
      {get_previous_question(state), state}
    else
      suburbs = Suburb.find_suburbs(message, Map.get(state, :state))
      case suburbs do
        [] -> { @retry, state }
        _ -> 
          next_question = Questions.get(:suburb)
          next_state = Map.merge(state, %{suburbs: suburbs, previou_step: :suburb, step: :what})
          {next_question, next_state}
      end
    end
  end

  def next(%{step: :what} = state, message) do
    case message do
      "yes" -> 
        next_question = Questions.get(:what_yes)
        next_state = Map.merge(state, %{what: "yes", step: :finish, previous_step: :where})
        {next_question, next_state}
      "no" ->
        next_question = Questions.get(:what_no)
        next_state = Map.merge(state, %{what: "no", step: :finish})
        {next_question, next_state}
      "back" -> { Questions.get(:budget), state }
      _ -> { @retry, state }
    end
  end
  

  # :finish -> :finish
  def next(%{step: :finish} = state, _) do
    next_question = [ {:text, "thank you"} ]
    {next_question, state}
  end

  defp get_previous_question(state) do
    state |> Map.get(:previous_step) |> Questions.get
  end
  
end