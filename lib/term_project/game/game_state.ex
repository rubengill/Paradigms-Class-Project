defmodule TermProject.GameState do
  @moduledoc """
  Represents the state of a game and provides functions to modify it.

  Responsibilities:
  - Tracks resources, units, and base health.
  - Applies actions to update the game state.
  """

  alias TermProject.Unit
  alias TermProject.ResourceManager

  defstruct tick: 0,
            units: [],
            resources: ResourceManager.initialize(),
            base: %{health: 1000},
            opponent_actions: []

  @type t :: %__MODULE__{
          tick: integer(),
          units: list(),
          resources: map(),
          base: map(),
          opponent_actions: list()
        }

  @doc """
  Creates a new game state with default values.
  """
  def new do
    %__MODULE__{}
  end

  @wood_update_interval 50  # 5 seconds
  @stone_update_interval 70 # 7 seconds
  @iron_update_interval 100 # 10 seconds

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

  defp buy_unit(resources, unit_type) do
    # Define resource costs for each unit type
    costs = case unit_type do
      :knight -> %{wood: 50, iron: 30}
      :archer -> %{wood: 30, stone: 20}
      :cavalry -> %{wood: 40, iron: 40}
      _ -> %{}
    end

    # Deduct resources
    case ResourceManager.deduct(resources, costs) do
      {:ok, updated_resources} -> updated_resources
      {:error, :insufficient_resources} ->
        IO.puts("Not enough resources to create #{unit_type}!")
        resources
    end
  end

  def auto_update_resources(state) do
    # Determine which resources to update based on the tick count
    update_wood = rem(state.tick, @wood_update_interval) == 0
    update_stone = rem(state.tick, @stone_update_interval) == 0
    update_iron = rem(state.tick, @iron_update_interval) == 0

    # Handle the updates
    updated_resources = ResourceManager.auto_update(
      state.resources,
      update_wood,
      update_stone,
      update_iron
    )

    # Return updated state
    %{state | resources: updated_resources}
  end

  def add_worker_to_unused(state, from) do
    updated_workers = ResourceManager.redistribute_worker(state.resources, from, :unused)
    %{state | resources: updated_workers}
  end

  def add_worker_to_resource(state, to) do
    updated_workers = ResourceManager.redistribute_worker(state.resources, :unused, to)
    %{state | resources: updated_workers}
  end
end
