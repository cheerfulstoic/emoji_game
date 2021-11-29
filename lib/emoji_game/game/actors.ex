defmodule EmojiGame.Game.Actors do
  def new do
    %{}
  end

  def set_position(actors, pid, new_position) do
    actor_update(actors, pid, :position, new_position)
  end

  def update_position(actors, pid, new_position) do
    if Map.has_key?(actors, pid) do
      {:ok, Map.update(
        actors,
        pid,
        %{pid => new_position},
        & Map.put(&1, :position, new_position)
      )}
    else
      {:error, "Player not registered"}
    end
  end

  def set_options(actors, pid, options) do
    actor_update(actors, pid, :options, options)
  end

  def get_position(actors, pid) do
    actors[pid][:position]
  end

  def get_option(actors, pid, key) do
    actors[pid][:options][key]
  end

  # def actor_registered?(actors, pid), do: Map.has_key?(actors, pid)

  def get_indicator(actors, pid) do
    actors
    |> Map.get(pid, %{})
    |> Map.get(:options, %{})
    |> Map.get(:indicator, :actor)
  end

  # DEPRECATED?
  def indicator_positions(actors) do
    Map.new(actors, fn {pid, details} -> {details.position, details[:options][:indicator] || :actor} end)
  end

  def register_conflicts(actors, pids) do
    permutations(pids)
    |> Enum.each(fn {pid1, pid2} ->
      register_conflict(actors, pid1, pid2)
    end)
  end

  # General!  Maybe move elsewhere
  defp permutations([]), do: []
  defp permutations([first | rest]) do
    Enum.map(rest, & {first, &1}) ++ permutations(rest)
  end


  def register_conflict(actors, pid1, pid2) do
    indicator1 = get_indicator(actors, pid1)
    indicator2 = get_indicator(actors, pid2)

    handle_conflict({pid1, indicator1}, {pid2, indicator2})
  end

  def handle_conflict({pid1, :paint}, {pid2, _indicator2}) do
    Process.send(pid1, :despawn, [])
    Process.send(pid2, :despawn, [])
  end
  def handle_conflict({pid1, _indicator1}, {pid2, :paint}) do
    Process.send(pid1, :despawn, [])
    Process.send(pid2, :despawn, [])
  end
  def handle_conflict({_pid1, _indicator1}, {_pid2, _indicator2}), do: nil

  def actor_positions(actors) do
    Enum.map(actors, fn {pid, details} -> {pid, details.position} end)
  end

  defp actor_update(actors, pid, key, value) do
    Map.update(
      actors,
      pid,
      %{key => value},
      & Map.put(&1, key, value)
    )
  end
end

