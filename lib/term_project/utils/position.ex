defmodule TermProject.Utils.Position do
  @moduledoc """
  Utility functions for position calculations.
  """

  def starting_position(player_id) do
    case player_id do
      1 -> %{x: 0, y: 0}
      2 -> %{x: 1000, y: 0}
      # TODO: Handle more players if necessary
      _ -> %{x: 0, y: 0}
    end
  end

  def enemy_base(player_id) do
    case player_id do
      1 -> %{x: 1000, y: 0}
      2 -> %{x: 0, y: 0}
      # TODO: Handle more players if necessary
      _ -> %{x: 1000, y: 0}
    end
  end

  def move_towards(position, target_position, speed) do
    dx = target_position.x - position.x
    dy = target_position.y - position.y
    distance = :math.sqrt(dx * dx + dy * dy)

    if distance == 0 do
      position
    else
      ratio = min(speed / distance, 1.0)
      %{x: position.x + ratio * dx, y: position.y + ratio * dy}
    end
  end

  def distance(pos1, pos2) do
    dx = pos1.x - pos2.x
    dy = pos1.y - pos2.y
    :math.sqrt(dx * dx + dy * dy)
  end
end
