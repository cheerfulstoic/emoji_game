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

  def indicator_positions(actors) do
    Map.new(actors, fn {pid, details} -> {details.position, details[:options][:indicator] || :actor} end)
  end

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

