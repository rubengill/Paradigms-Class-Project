defmodule TermProject.GameState do
  alias TermProject.Unit

  defstruct tick: 0,
            units: [],
            resources: %{wood: 100, stone: 100, iron: 100},
            base: %{health: 1000},
            opponent_actions: []

  def apply_action(state, {:create_unit, unit_type}) do
    # Dynamically create a unit using its module
    unit_module = unit_module_for(unit_type)
    unit_stats = unit_module.stats()
    resources = deduct_resources(state.resources, unit_type)

    units = [%{unit_stats | type: unit_type} | state.units]
    %{state | resources: resources, units: units}
  end

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
