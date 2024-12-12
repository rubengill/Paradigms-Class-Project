defmodule TermProject.Utils.Serializer do
  @moduledoc """
  Serializes game state into a format suitable for clients.
  """

  def serialize_state(state) do
    %{
      units: Enum.map(state.units, fn unit ->
        %{
          id: unit.id,
          type: unit.type,
          position: unit.position,
          owner: unit.owner,
          health: unit.health
          # TODO: Add other unit attributes if necessary
        }
      end),
      tick: state.tick
      # TODO: Serialize other state elements (e.g., resources, players) if needed
    }
  end
end
