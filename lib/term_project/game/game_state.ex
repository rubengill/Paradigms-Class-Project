defmodule TermProject.GameState do
  alias TermProject.Unit

  defstruct tick: 0,
            units: [],
            resources: TermProject.ResourceManager.initialize(),
            base: %{health: 1000},
            opponent_actions: []

  @wood_update_interval 50  # 5 seconds
  @stone_update_interval 70 # 7 seconds
  @iron_update_interval 100 # 10 seconds

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
    # Define resource costs for each unit type
    costs = case unit_type do
      :knight -> %{wood: 50, iron: 30}
      :archer -> %{wood: 30, stone: 20}
      :cavalry -> %{wood: 40, iron: 40}
      _ -> %{}
    end

    # Deduct resources
    case TermProject.ResourceManager.deduct(resources, costs) do
      {:ok, updated_resources} -> updated_resources
      {:error, :insufficient_resources} ->
        IO.puts("Not enough resources to create #{unit_type}!")
        resources
    end
  end

  def update_resources(state) do
    # Determine which resources to update based on the tick count
    update_wood = rem(state.tick, @wood_update_interval) == 0
    update_stone = rem(state.tick, @stone_update_interval) == 0
    update_iron = rem(state.tick, @iron_update_interval) == 0

    # Handle the updates
    updated_resources = TermProject.ResourceManager.auto_update(
      state.resources,
      update_wood,
      update_stone,
      update_iron
    )

    # Return updated state
    %{state | resources: updated_resources}
  end
end
