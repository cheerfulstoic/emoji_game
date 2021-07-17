defmodule EmojiGame.Repo do
  use Ecto.Repo,
    otp_app: :emoji_game,
    adapter: Ecto.Adapters.Postgres
end
