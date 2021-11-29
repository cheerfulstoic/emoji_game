defmodule EmojiGame.Game.Positions do
  @dimension 1_000

  def new do
    %{}
  end

  def move_item(positions, old_position, new_position, item) do
    positions
    |> Map.update(old_position, MapSet.new(), &MapSet.delete(&1, item))
    |> Map.update(new_position, MapSet.new([item]), &MapSet.put(&1, item))
  end

  def place_item(positions, position, item) do
    Map.update(positions, position, MapSet.new([item]), & MapSet.put(&1, item))
  end

  def get_item(positions, position) do
    get_items(positions, position)
    |> Enum.at(0)
  end

  def get_items(positions, position) do
    Map.get(positions, position, MapSet.new())
  end

  def remove_item(positions, position, item) do
    positions
    |> Map.update(position, MapSet.new(), &MapSet.delete(&1, item))
  end

  def randomly_populate(positions, item, times) do
    Enum.reduce(0..times, positions, fn _index, positions ->
      x = Enum.random(0..@dimension)
      y = Enum.random(0..@dimension)

      place_item(positions, {x, y}, item)
    end)
  end

end

