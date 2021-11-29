defmodule EmojiGameWeb.GameLive do
  use EmojiGameWeb, :live_view

  alias EmojiGameWeb.Components

  @impl true
  def mount(_params, _session, socket) do
    {:ok, true} = EmojiGame.Game.register({11, 11}, %{return_view_update: true, indicator: :player})

    {:ok,
      socket
      |> assign(:shift_key, false)
      |> assign(:position, {11, 11})
      |> assign(:board_positions, %{})
    }
  end

  def render(assigns) do
    ~L"""
    <%= live_component(Components.Board, id: :board, positions: @board_positions, position: @position) %>
    """
  end

  @impl true
  def handle_event("keydown", %{"key" => key}, socket) do
    new_socket = 
      case key do
        "ArrowRight" -> move_player(socket, :right)
        "ArrowLeft" -> move_player(socket, :left)
        "ArrowUp" -> move_player(socket, :up)
        "ArrowDown" -> move_player(socket, :down)
        # TODO: Non-arrow keys shouldn't cause a move/refresh, ideally
        "w" -> spawn_paint(socket, :up)
        "s" -> spawn_paint(socket, :down)
        "a" -> spawn_paint(socket, :left)
        "d" -> spawn_paint(socket, :right)
        other -> socket
      end

    {:noreply, new_socket}
  end

  defp move_player(socket, direction) do
    new_position = new_player_position(direction, socket.assigns.position)

    case EmojiGame.Game.move(new_position) do
      {:ok, true} ->
        socket
        |> assign(:position, new_position)
    end
  end

  defp new_player_position(:right, {x, y}), do: {x + 1, y}
  defp new_player_position(:left, {x, y}), do: {max(x - 1, 0), y}
  defp new_player_position(:up, {x, y}), do: {x, max(y - 1, 0)}
  defp new_player_position(:down, {x, y}), do: {x, y + 1}

  defp spawn_paint(socket, direction) do
    EmojiGame.ObjectSupervisor.spawn_paint(socket.assigns.position, direction)

    socket
  end

  @impl true
  def handle_event("keydown", %{"key" => other}, socket) do
    {:noreply, socket}
  end


  @impl true
  def handle_event("keyup", %{"key" => other}, socket) do
    {:noreply, socket}
  end


  @impl true
  def handle_info({:view_update, positions}, socket) do
    {:noreply,
      socket
      |> assign(:board_positions, positions)}
  end

  @impl true
  def handle_info(:despawn, state) do
    # TODO: HANDLE THIS!

    {:noreply, state}
  end
end
