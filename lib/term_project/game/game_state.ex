defmodule TermProject.GameState do
  @moduledoc """
  Represents the state of a game and provides functions to modify it.

  Responsibilities:
  - Tracks resources, units, and base health.
  - Applies actions to update the game state.
  """

  alias TermProject.Unit

  # Field dimensions
  @field_width 1000
  @field_height 600

  # Base positions
  @base_positions %{
    1 => %{x: 0, y: @field_height/2},     # Left side
    2 => %{x: 1000, y: @field_height/2}   # Right side
  }

  defstruct tick: 0,
            units: [],
            resources: %{wood: 100, stone: 100, iron: 100},
            bases: %{
              1 => %{position: nil, health: 1000},
              2 => %{position: nil, health: 1000}
            },
            field: %{
              width: @field_width,
              height: @field_height,
              base_positions: @base_positions
            },
            opponent_actions: []

  @type t :: %__MODULE__{
          tick: integer(),
          units: list(),
          resources: map(),
          bases: map(),
          field: map(),
          opponent_actions: list()
        }

  @doc """
  Creates a new game state with default values.
  """
  def new do
    %__MODULE__{
      bases: %{
        1 => %{position: @base_positions[1], health: 1000},
        2 => %{position: @base_positions[2], health: 1000}
      }
    }
  end

  @doc """
  Applies an action (e.g., create unit, attack) to the game state.
  """
  def apply_action(state, {:create_unit, unit_type}) do
    # Dynamically create a unit using its module
    unit_module = unit_module_for(unit_type)
    unit_stats = unit_module.stats()
    resources = deduct_resources(state.resources, unit_type)

    units = [%{unit_stats | type: unit_type} | state.units]
    %{state | resources: resources, units: units}
  end

  @doc """
  Applies a list of opponent actions to the game state.
  """
  def apply_opponent_actions(state, actions) do
    Enum.reduce(actions, state, &apply_action(&2, &1))
  end

  # Private Helpers

  defp unit_module_for(:archer), do: TermProject.Units.Archer
  defp unit_module_for(:knight), do: TermProject.Units.Knight
  defp unit_module_for(:cavalry), do: TermProject.Units.Cavalry

  defp deduct_resources(resources, unit_type) do
    # Deduct resources based on unit type
    case unit_type do
      :knight -> %{resources | wood: resources.wood - 50, iron: resources.iron - 30}
      :archer -> %{resources | wood: resources.wood - 30, stone: resources.stone - 20}
      :cavalry -> %{resources | wood: resources.wood - 40, iron: resources.iron - 40}
      _ -> resources
    end
  end
end
