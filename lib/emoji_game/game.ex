defmodule EmojiGame.Game do
  use GenServer

  alias EmojiGame.Game.Actors

  @dimension 1_000

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def register(starting_position, options) do
    GenServer.call(__MODULE__, {:register, starting_position, options})
  end

  # Probably the move function should allow you to do things like
  # move a certain number of steps in a certain direction, but not
  # just to move anywhere
  def move(new_position) do
    GenServer.call(__MODULE__, {:move, new_position})
  end


  # Callbacks

  @impl true
  def init(_) do
    Process.flag(:trap_exit, true)

    Process.send_after(self(), :update_players, 100)

    {:ok, %{map: populate(), actors: Actors.new()}, {:continue, :start_actors}}
  end

  @impl true
  def handle_continue(:start_actors, state) do
    Task.Supervisor.async_nolink(EmojiGame.TaskSupervisor, fn ->
      for i <- 1..100 do
      Process.sleep(10)
        if(rem(i,500) == 0, do: IO.inspect(i, label: :i))
        # TODO: Change so that there is a function in `EmojiGame.Actor` which does the below
        {:ok, _} = DynamicSupervisor.start_child(
          EmojiGame.ActorSupervisor,
          %{start: {EmojiGame.Actor, :start_link, [nil]}, id: :"actor#{i}"}
        )
      end
      IO.puts("DONE WITH ACTORS!")
    end)


    {:noreply, state}
  end

  # If the task succeeds...
  def handle_info({ref, result}, state) do
    IO.puts("SUCCESS!")
    # The task succeed so we can cancel the monitoring and discard the DOWN message
    Process.demonitor(ref, [:flush])

    # {url, state} = pop_in(state.tasks[ref])
    # IO.puts "Got #{inspect(result)} for URL #{inspect url}"
    {:noreply, state}
  end

  # If the task fails...
  def handle_info({:DOWN, ref, _, _, reason}, state) do
    IO.puts("DOWN")
    # {url, state} = pop_in(state.tasks[ref])
    # IO.puts "URL #{inspect url} failed with reason #{inspect(reason)}"
    {:noreply, state}
  end




  defp populate() do
    # TREES!!!!
    Enum.reduce(0..1_000_000, %{}, fn _index, map ->
      x = Enum.random(0..@dimension)
      y = Enum.random(0..@dimension)

      Map.put(map, {x, y}, :tree)
    end)
  end


  @impl true
  def handle_call({:register, starting_position, options}, {from_pid, _}, state) do
    Process.link(from_pid)

    actors =
      state.actors
      |> Actors.set_position(from_pid, starting_position)
      |> Actors.set_options(from_pid, options)

    state = Map.put(state, :actors, actors)

    send_view_update_to(state, from_pid)

    {:reply, {:ok, true}, state}
  end

  @impl true
  def handle_call({:move, new_position}, {from_pid, _}, state) do
    # Will this cause problems in responding?
    report_metrics()

    case Actors.update_position(state.actors, from_pid, new_position) do
      {:ok, actors} ->
        state = Map.put(state, :actors, actors)

        send_view_update_to(state, from_pid)

        {:reply, {:ok, true}, state}

      {:error, message} ->
        {:reply, {:error, message}, state}
    end
  end

  @impl true
  def handle_continue(:start_actors, state) do
    Task.Supervisor.async_nolink(EmojiGame.TaskSupervisor, fn ->
      for i <- 1..13_000 do
        {:ok, _} = DynamicSupervisor.start_child(
          EmojiGame.ActorSupervisor,
          %{start: {EmojiGame.Actor, :start_link, [nil]}, id: :"actor#{i}"}
        )
      end
    end)


    {:noreply, state}
  end

  def handle_info(:update_players, state) do
    send_view_updates_to_all(state)

    Process.send_after(self(), :update_players, 200)

    {:noreply, state}
  end

  def send_view_updates_to_all(state) do
    for {pid, position} <- Actors.actor_positions(state.actors) do
      send_view_update_to(state, pid)
    end
  end

  def send_view_update_to(state, pid) do
    if Actors.get_option(state.actors, pid, :return_view_update) do
      position = Actors.get_position(state.actors, pid)
      Process.send(pid, {:view_update, section_for(state, position)}, [])
    end
  end

  @section_radius 10
  defp section_for(state, {x, y}) do
    indicator_positions = Actors.indicator_positions(state.actors)

    Enum.reduce((y - @section_radius)..(y + @section_radius - 1), %{}, fn y, result ->
      Enum.reduce((x - @section_radius)..(x + @section_radius - 1), result, fn x, result ->
        value =
          if Map.has_key?(indicator_positions, {x, y}) do
            indicator_positions[{x, y}]
          else
            Map.get(state.map, {x, y}, nil)
          end

        if(value, do: Map.put(result, {x, y}, value), else: result)
      end)
    end)
  end

  @impl true
  def handle_info({:EXIT, pid, _reason}, state) do
    {:noreply, Map.update!(state, :actors, & Map.delete(&1, pid))}
  end

  # Helpers

  def report_metrics do
    pid = Process.whereis(__MODULE__)
    {:message_queue_len, length} = Process.info(pid, :message_queue_len)

    :telemetry.execute(
      [:emoji_game, :game, :queue],
      %{length: length},
      %{ }
    )

  end

end
