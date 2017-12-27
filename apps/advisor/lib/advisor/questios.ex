defmodule Advisor.Questions do
  @questions %{
    retry: [ 
      {:choice, "Sorry, I don't quite understand what you said, do you want to", [{"restart the conversation", "restart"}, {"answer the question again", "back"}]}
    ],
    restart: [
      {:text,  "resetting everything and let's restart"},
      { :choice, "what's the purpose of the property?", [{"invest", "inv"}, {"owner occupy", "resi"}]}  
    ],
    start: [ 
      { :text, "Hey, nice to talk to you. I hope I can help you with your property journey. I am going to ask you a few questions so that I can give you appropriate advice"},
      { :choice, "what's the purpose of the property?", [{"invest", "inv"}, {"owner occupy", "resi"}]}
    ],
    greeting: [
      { :choice, "what's the purpose of the property?", [{"invest", "inv"}, {"owner occupy", "resi"}]}
    ],
    purpose: [ {:choice, "which state are you looking", 
    [ {"NSW", "nsw"}, 
      {"VIC", "vic"},
      {"QLD", "qld"},
      {"SA", "sa"},
      {"WA", "wa"},
      {"NT", "nt"},
      {"TAS", "tas"},
    ]}],
    province: [ 
      {:choice, "what's your budget", 
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
    ]}], 
    budget: [ {:choice, "Do you have clear idea on which suburb to buy", 
    [
      {"Yes", "yes"}, 
      {"Not yet", "no"},
    ]}],
    suburb_yes: [ {:text, "Perfect, please tell me either the post code or suburb name"} ],
    suburb_no: [ {:text, "No worries, that's why I am here to help :)"} ],
    suburb: [ {:choice, "Got your suburb sorted. Do you know exactly what kind of property to buy", 
    [
      {"Yes", "yes"}, 
      {"Not yet", "no"},
    ]}],
    what_yes: [ {:text, "That's great, how many bedroom do you want"} ],
    what_no: [ {:text, "Not a problem, let us figure out"} ],
  }


  def get(key) do
    Map.fetch!(@questions, key)
  end
end