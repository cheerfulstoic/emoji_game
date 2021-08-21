defmodule EmojiGameWeb.Components.Board do
  use Phoenix.LiveComponent

  @dimension 50

  # Note: LiveView doesn't update automatically based on the GenServer changing
  # (of course)
  #
  # I think maybe the Game server will need to have an idea for which clients are
  # connected and what "box" from the map that they are currently viewing and then
  # send an update to the clients when there is a change
  #
  # Maybe there should be individual processes for each client which monitor changes
  # to that box?  Do we just need to watch for changes from actors?

  def render(assigns) do
    dimension = @dimension
    cell_count = @dimension * @dimension

    ~L"""
    <% {x_pos, y_pos} = @position %>
    <div id="board" phx-window-keydown="move">
      <% # hard-code 21 for now.  Need to adjust based on game server %>
      <%= for y <- (y_pos-10..y_pos+10) do %>
        <%= for x <- (x_pos-10..x_pos+10) do %>
          <% cell = @positions[{x, y}] %>
          <div class="cell" style="grid-column-start: <%= x - (x_pos - 10) + 1 %>">
            <%
              emoji =
                case cell do
                  :tree -> "🌳"
                  :player -> "😁"
                  :actor -> "🤖"
                  other -> other
                end
            %>
            <%= emoji %>
          </div>
        <% end %>
      <% end %>
    </div>

    <style>
    #board {
      display: grid;
      grid-template-columns: repeat(<%= dimension %>, 24px);
      background-color: #BBB;
    }
    .cell {
      border: 1px solid purple;
      width: 24px;
      height: 24px;
}
    }
    </style>
    """
  end
end
