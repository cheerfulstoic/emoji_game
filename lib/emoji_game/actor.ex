defmodule EmojiGame.Actor do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  # Callbacks

  @impl true
  def init(_) do
    {:ok, {10, 10}, {:continue, :register}}
  end

  @impl true
  def handle_continue(:register, position) do
    {:ok, true} = EmojiGame.Game.register(position, %{})

    ms = trunc(:rand.uniform() * 2000) + 1000
    Process.send_after(self(), :move, ms)

    {:noreply, position}
  end

  @move_shift_amounts [-1, 0, 1]

  @impl true
  def handle_info(:move, {x, y}) do
    # IO.inspect("Moving")

    new_x = x + Enum.random(@move_shift_amounts)
    new_y = y + Enum.random(@move_shift_amounts)

    :telemetry.span(
      [:emoji_game, :actor, :move_time],
      %{},
      fn ->
        {EmojiGame.Game.move({new_x, new_y}), %{}}
      end
    )

    Process.send_after(self(), :move, 1_000)

    {:noreply, {new_x, new_y}}
  end

  @impl true
  def handle_info({:view_update, section}, state) do
    # Ignore for now

    {:noreply, state}
  end
end
