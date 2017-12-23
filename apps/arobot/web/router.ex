defmodule Arobot.Router do
  use Arobot.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Arobot do
    pipe_through :api

    resources "/webhook", WebhookController
  end
end
