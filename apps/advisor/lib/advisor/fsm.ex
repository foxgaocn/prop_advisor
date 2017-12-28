alias Advisor.{Suburb, Questions}

defmodule Advisor.Fsm do
  @retry  [ 
    {:choice, "Sorry, I don't quite understand what you said, do you want to", [{"restart the conversation", "restart"}, {"answer the question again", "back"}]}
  ]

  #:restart -> :purpose
  def next(_, "restart") do
    {Questions.get(:restart), %{step: :purpose, previous_step: :greeting}}
  end

  #:start -> :purpose
  def next(%{step: :start}, _) do
    {Questions.get(:start), %{step: :purpose, previous_step: :greeting}}
  end

  #:greeting -> :purpose
  def next(%{step: :greeting}, _) do
    {Questions.get(:greeting), %{step: :purpose, previous_step: :greeting}}
  end

  # :purpose -> :province
  def next(%{step: :purpose} = state, message) do
    next_question = Questions.get(:purpose)

    case message do
      "resi" -> { next_question, %{step: :province, purpose: "resi"} }
      "inv" -> { next_question, %{step: :province, purpose: "inv"} }
      "back" -> go_back(state)
      _ -> { @retry, state }
    end
  end

  # :province -> :budget
  def next(%{step: :province} = state, message) do
    next_question = Questions.get(:province)
    
    cond do
      Enum.member?(["nsw", "vic", "qld", "nt", "tas", "sa", "wa"], message) -> 
        { next_question, Map.merge(state, %{step: :budget, previous_step: :province, state: message})}
      message == "back" -> {Questions.get(:purpose), state}
      true -> { @retry, state }
    end
  end

  # :budget -> :where
  def next(%{step: :budget} = state, message) do
    next_question = Questions.get(:budget)
    if (message == "back") do
      go_back(state)
    else
      case Integer.parse(message) do
        :error -> { @retry, state }
        {budget, _} -> { next_question, Map.merge(state, %{budget: budget, step: :where, previous_step: :budget})}
      end
    end
  end

  # :where -> :suburb | :location
  def next(%{step: :where} = state, message) do
    case message do
      "yes" -> 
        next_question = Questions.get(:suburb_yes)
        next_state = Map.merge(state, %{where: "yes", step: :suburb, previous_step: :suburb_yes})
        {next_question, next_state}
      "no" ->
        next_question = Questions.get(:suburb_no)
        next_state = Map.merge(state, %{where: "no", step: :location, previous_step: :suburb_no})
        {next_question, next_state}
      "back" -> go_back(state)
      _ -> { @retry, state }
    end
  end

  # :suburb -> :what
  def next(%{step: :suburb} = state, message) do
    if(message == "back") do
      go_back(state)
    else
      suburbs = Suburb.find_suburbs(message, Map.get(state, :state))
      case suburbs do
        [] -> { @retry, state }
        _ -> 
          next_question = Questions.get(:suburb)
          next_state = Map.merge(state, %{previous_step: :suburb, step: :what, suburbs: suburbs})
          {next_question, next_state}
      end
    end
  end

  # :what -> :bedroom | :commute_to
  def next(%{step: :what} = state, message) do
    case message do
      "yes" -> 
        next_question = Questions.get(:what_yes)
        next_state = Map.merge(state, %{what: "yes", step: :finish, previous_step: :what_yes})
        {next_question, next_state}
      "no" ->
        next_question = Questions.get(:what_no)
        next_state = Map.merge(state, %{what: "no", step: :finish, previous_step: :what_no})
        {next_question, next_state}
      "back" -> go_back(state)
      _ -> { @retry, state }
    end
  end
  

  # :finish -> :finish
  def next(%{step: :finish} = state, _) do
    next_question = [ {:text, "thank you"} ]
    {next_question, state}
  end

  defp go_back(state) do
    #IO.inspect(state)
    {state |> Map.get(:previous_step) |> Questions.get , state}
  end
  
end