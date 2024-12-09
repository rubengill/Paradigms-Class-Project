defmodule TermProject.GameState do
  defstruct tick: 0,
            units: [],
            resources: %{wood: 100, stone: 100, iron: 100},
            base: %{health: 1000},
            opponent_actions: []

  @type t :: %__MODULE__{
          tick: integer(),
          units: list(),
          resources: map(),
          base: map(),
          opponent_actions: list()
        }

  def new() do
    %__MODULE__{}
  end

  def apply_action(state, action) do
    case action do
      {:create_unit, unit_type} ->
        resources = deduct_resources(state.resources, unit_type)
        units = [%{type: unit_type, health: 100} | state.units]
        %{state | resources: resources, units: units}

      {:attack, damage} ->
        %{state | base: %{state.base | health: state.base.health - damage}}

      _ -> state
    end
  end

  def apply_opponent_actions(state, actions) do
    Enum.reduce(actions, state, &apply_action(&2, &1))
  end

  defp deduct_resources(resources, unit_type) do
    case unit_type do
      :knight -> %{resources | wood: resources.wood - 50, iron: resources.iron - 30}
      :archer -> %{resources | wood: resources.wood - 30, stone: resources.stone - 20}
      _ -> resources
    end
  end
end
