defmodule TermProject.GameState do
  @moduledoc """
  Represents the state of a game and provides functions to modify it.

  Responsibilities:
  - Tracks resources, units, and base health.
  - Applies actions to update the game state.
  """

  alias TermProject.Unit
  alias TermProject.UnitCosts
  alias TermProject.ResourceManager

  # Field dimensions
  @field_width 1000
  @field_height 600

  # Base positions
  @base_positions %{
    # Left side
    1 => %{x: 0, y: @field_height / 2},
    # Right side
    2 => %{x: 1000, y: @field_height / 2}
  }

  # Resource update intervals (based off of 100ms tick speed)
  # 5 seconds
  @wood_update_interval 50
  # 7 seconds
  @stone_update_interval 70
  # 12 seconds
  @iron_update_interval 120

  defstruct [
    tick: 0,
    units: [],
    resources: %{
      1 => %{
        workers: %{unused: 0, wood: 3, stone: 3, iron: 3},
        amounts: %{wood: 200, stone: 100, iron: 20}
      },
      2 => %{
        workers: %{unused: 0, wood: 3, stone: 3, iron: 3},
        amounts: %{wood: 200, stone: 100, iron: 20}
      }
    },
    bases: %{},
    field: %{width: 1000, height: 600, base_positions: %{}},
    opponent_actions: [],
    players: %{}
  ]

  @type t :: %__MODULE__{
          tick: integer(),
          units: list(),
          resources: map(),
          bases: map(),
          field: map(),
          opponent_actions: list(),
          players: map()
        }

  @doc """
  Creates a new game state with default values.
  """

  # Add this after the @type definition:

  @doc """
  Creates a new game state with default values.
  """
  def new do
    %__MODULE__{
      tick: 0,
      units: [],
      resources: ResourceManager.initialize(),
      bases: %{
        1 => %{position: @base_positions[1], health: 1000},
        2 => %{position: @base_positions[2], health: 1000}
      },
      field: %{
        width: @field_width,
        height: @field_height,
        base_positions: @base_positions
      },
      opponent_actions: []
    }
  end

  @doc """
  Creates a new unit and adds it to the game state.
  """
  def apply_action(state, {:create_unit, unit_type, player_id}) do
    # Get player's resources
    player_resources = get_in(state.resources, [player_id])
    unit_cost = UnitCosts.cost(unit_type)

    if has_sufficient_resources?(player_resources.amounts, unit_cost) do
      # Update resources
      updated_resources = update_in(
        state.resources,
        [player_id, :amounts],
        &deduct_resources(&1, unit_cost)
      )

      # Create unit with correct player_id
      new_unit = create_unit(unit_type, player_id, state)

      {:ok, %{state |
        resources: updated_resources,
        units: [new_unit | state.units]
      }}
    else
      {:error, :insufficient_resources}
    end
  end

  defp has_sufficient_resources?(current, cost) do
    Enum.all?(cost, fn {resource, amount} ->
      Map.get(current, resource, 0) >= amount
    end)
  end

  defp deduct_resources(current, cost) do
    Enum.reduce(cost, current, fn {resource, amount}, acc ->
      Map.update!(acc, resource, &(&1 - amount))
    end)
  end

  defp create_unit(unit_type, player_id, state) do
    base_position = state.bases[player_id].position

    %{
      id: System.unique_integer([:positive]),
      type: unit_type,
      health: 100,
      owner: player_id,
      position: base_position # Spawn at player's base position
    }
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
    costs = UnitCosts.cost(unit_type)

    # Deduct resources
    case ResourceManager.deduct(resources, costs) do
      {:ok, updated_resources} ->
        updated_resources

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
    costs = %{wood: 500, stone: 150, iron: 120}

    # Deduct resources
    case ResourceManager.deduct(resources, costs) do
      {:ok, updated_resources} ->
        updated_resources

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
  def auto_update_resources(%{resources: resources} = state) do
    updated_resources = Enum.reduce(resources, %{}, fn {player_id, player_resources}, acc ->
      Map.put(acc, player_id, update_player_resources(player_resources))
    end)

    %{state | resources: updated_resources}
  end

  defp update_player_resources(%{workers: workers, amounts: amounts}) do
    new_amounts = %{
      wood: amounts.wood + (workers.wood * 2),
      stone: amounts.stone + workers.stone,
      iron: amounts.iron + workers.iron
    }
    %{workers: workers, amounts: new_amounts}
  end

  @doc """
  Moves a worker from a specified resource to the `:unused` pool.

  Parameters:
    - resources (map): The current resource map.
    - from (atom): The resource key to remove a worker from (`:wood`, `:stone`, or `:iron`).

  Returns:
    - The updated resource map with the worker moved to the `:unused` pool.
  """
  def add_worker_to_unused(resources, from),
    do: ResourceManager.redistribute_worker(resources, from, :unused)

  @doc """
  Moves a worker from the `:unused` pool to a specified resource.

  Parameters:
    - resources (map): The current resource map.
    - to (atom): The resource key to assign a worker to (`:wood`, `:stone`, or `:iron`).

  Returns:
    - The updated resource map with the worker added to the specified resource.
  """
  def add_worker_to_resource(resources, to),
    do: ResourceManager.redistribute_worker(resources, :unused, to)
end
