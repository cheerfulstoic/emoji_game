# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :emoji_game,
  ecto_repos: [EmojiGame.Repo]

# Configures the endpoint
config :emoji_game, EmojiGameWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "+8LQwQEKkh/8UYcQ06uXwD0cgYjg4jgkNYkqzFPSh/otVIJyX+Z93U9eogKe/6AU",
  render_errors: [view: EmojiGameWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: EmojiGame.PubSub,
  live_view: [signing_salt: "Hx36eate"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
