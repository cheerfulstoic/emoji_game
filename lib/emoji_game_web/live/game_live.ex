defmodule EmojiGameWeb.GameLive do
  use EmojiGameWeb, :live_view

  alias EmojiGameWeb.Components

  @impl true
  def mount(_params, _session, socket) do
    {:ok, true} = EmojiGame.Game.register({11, 11}, %{return_view_update: true, indicator: :player})

    {:ok,
      socket
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
  def handle_event("move", %{"key" => key}, socket) do
    {x, y} = socket.assigns.position

    new_position =
      case key do
        "ArrowRight" -> {x + 1, y}
        "ArrowLeft" -> {max(x - 1, 0), y}
        "ArrowUp" -> {x, max(y - 1, 0)}
        "ArrowDown" -> {x, y + 1}
        other -> {x, y}
      end

    # TODO: Non-arrow keys shouldn't cause a move/refresh, ideally

    case EmojiGame.Game.move(new_position) do
      {:ok, true} ->
        {:noreply,
          socket
          |> assign(:position, new_position)}
    end
  end

  @impl true
  def handle_event("move", %{"key" => other}, socket) do
    {:noreply, socket}
  end


  @impl true
  def handle_info({:view_update, positions}, socket) do
    {:noreply,
      socket
      |> assign(:board_positions, positions)}
  end
end
