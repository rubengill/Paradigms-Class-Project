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
  @iron_update_interval 120 # 12 seconds

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

  @doc """
  Attempts to purchase a unit by deducting the required resources.

  Parameters:
    - resources (map): The current resource map.
    - unit_type (atom): The type of unit to purchase (`:knight`, `:archer`, or `:cavalry`).

  Returns:
    - The updated resource map if the purchase is successful.
    - The original resource map if there are insufficient resources.
  """
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

  @doc """
  Attempts to purchase new workers by deducting the required resources.

  Parameters:
    - resources (map): The current resource map.

  Returns:
    - The updated resource map with additional workers added to the `:unused` pool if the purchase is successful.
    - The original resource map if there are insufficient resources.
  """
  def buy_new_workers(resources) do
    costs = %{wood: 300, stone: 150, iron: 120}

    # Deduct resources
    case ResourceManager.deduct(resources, costs) do
      {:ok, updated_resources} -> updated_resources
      {:error, :insufficient_resources} ->
        IO.puts("Not enough resources to add new workers!")
        resources
    end
  end

  @doc """
  Automatically updates resources based on the current tick count.

  Parameters:
    - resources (map): The current resource map.

  Returns:
    - The updated game state with resources adjusted according to the current tick.
  """
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
    updated_resources
  end

  @doc """
  Moves a worker from a specified resource to the `:unused` pool.

  Parameters:
    - resources (map): The current resource map.
    - from (atom): The resource key to remove a worker from (`:wood`, `:stone`, or `:iron`).

  Returns:
    - The updated resource map with the worker moved to the `:unused` pool.
  """
  def add_worker_to_unused(resources, from), do: ResourceManager.redistribute_worker(resources, from, :unused)

  @doc """
  Moves a worker from the `:unused` pool to a specified resource.

  Parameters:
    - resources (map): The current resource map.
    - to (atom): The resource key to assign a worker to (`:wood`, `:stone`, or `:iron`).

  Returns:
    - The updated resource map with the worker added to the specified resource.
  """
  def add_worker_to_resource(resources, to), do: ResourceManager.redistribute_worker(resources, :unused, to)
end
