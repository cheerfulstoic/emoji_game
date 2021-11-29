defmodule EmojiGame.ObjectSupervisor do
  # Automatically defines child_spec/1
  use DynamicSupervisor

  def spawn_actor() do
    {:ok, _} = DynamicSupervisor.start_child(
      __MODULE__,
      %{start: {EmojiGame.Actor, :start_link, [nil]}, id: String.to_atom(UUID.uuid1()), restart: :transient}
    )
  end

  def spawn_paint(position, direction) do
    {:ok, _} = DynamicSupervisor.start_child(
      __MODULE__,
      %{start: {EmojiGame.Paint, :start_link, [{position, direction, self()}]}, id: String.to_atom(UUID.uuid1()), restart: :transient}
    )
  end

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
