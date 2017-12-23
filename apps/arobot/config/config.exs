# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :arobot,
  ecto_repos: [Arobot.Repo]

# Configures the endpoint
config :arobot, Arobot.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "S3L6aSqOtOZL7YxBKD3qreXxNljyxrHQngEPD3y9jpuYDgSWNAo3bWssFABQA1Bc",
  render_errors: [view: Arobot.ErrorView, accepts: ~w(json)],
  pubsub: [name: Arobot.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
