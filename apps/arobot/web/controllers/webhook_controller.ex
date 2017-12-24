defmodule Arobot.WebhookController do
  use Arobot.Web, :controller

  @verify_token "abcd"
  
  def create(conn, %{"entry"=>entry, "object"=>"page"}=body) do
    
    message = entry
      |> List.first
      |> Map.fetch!("messaging")
      |> List.first
    sender_id = message["sender"]["id"]
    text = message["message"]["text"]
    reply(sender_id, text)
    text conn, "ok"
  end

  def index(conn, %{
      "hub.mode"=> "subscribe", 
      "hub.verify_token" => @verify_token,
      "hub.challenge" => challenge}) do
    text conn, challenge
  end

  defp reply(sender_id, message) do
    message
      |> Advisor.Worker.next
      |> Enum.map(&send_message(sender_id, &1))
  end

  defp send_message(sender_id, {:text, content}) do
    body = %{
      "messaging_type": "RESPONSE",
      "recipient": %{
        "id": sender_id,
      },
      "message": %{
        "text": content
      }
    } |> Poison.encode!

    IO.inspect body
    
    HTTPoison.post "https://graph.facebook.com/v2.6/me/messages?access_token=#{System.get_env("PAGE_ACCESS_TOKEN")}",
      body,
      [{"Content-Type", "application/json"}]
  end

  defp send_message(sender_id, {:choice, content}) do
    body = %{
      "messaging_type": "RESPONSE",
      "recipient": %{
        "id": sender_id,
      },
      "message": %{
        "text": "quick reply",
        "quick_replies": Enum.map(content, fn(c) ->
          %{
            "content_type": "text",
            "title": elem(c, 0),
            "payload": elem(c, 1)
          } end )
      }
    } |> Poison.encode!

    IO.inspect body

    HTTPoison.post "https://graph.facebook.com/v2.6/me/messages?access_token=#{System.get_env("PAGE_ACCESS_TOKEN")}",
      body,
      [{"Content-Type", "application/json"}]
  end
  
end