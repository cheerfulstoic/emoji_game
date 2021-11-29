defmodule EmojiGame.Paint do
  use GenServer

  def start_link({position, direction, shooter_pid}) do
    GenServer.start_link(__MODULE__, {position, direction, shooter_pid})
  end

  # Callbacks

  @delay 100
  @life 3_000

  @impl true
  def init({position, direction, shooter_pid}) do
    {:ok, true} = EmojiGame.Game.register(position, %{indicator: :paint})

    Process.send_after(self(), :move, @delay)
    born = DateTime.utc_now()

    {:ok, {position, direction, shooter_pid, born}}
  end

  @impl true
  def handle_info(:move, {position, direction, shooter_pid, born}) do
    new_position = shift(position, direction)

    :telemetry.span(
      [:emoji_game, :paint, :move_time],
      %{},
      fn ->
        {EmojiGame.Game.move(new_position), %{}}
      end
    )

    Process.send_after(self(), :move, @delay)

    if DateTime.diff(DateTime.utc_now(), born) <= 3 do
      {:noreply, {new_position, direction, shooter_pid, born}}
    else
      {:stop, :normal, {new_position, direction, shooter_pid, born}}
    end
  end

  def shift({x, y}, :up), do: {x, y - 1}
  def shift({x, y}, :down), do: {x, y + 1}
  def shift({x, y}, :left), do: {x - 1, y}
  def shift({x, y}, :right), do: {x + 1, y}

  @impl true
  def handle_info(:despawn, state) do
    IO.puts("PAINT DESPAWNING!")
    {:stop, :normal, state}
  end

  # @impl true
  # def terminate(:normal, {{x, y}, shooter_pid, born}) do
  # end
end

