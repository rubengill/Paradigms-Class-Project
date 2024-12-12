defmodule TermProject.Game do
  @moduledoc """
  Manages the game loop and overall state.

  Responsibilities:
  - Spawning units
  - Updating game state each tick
  - Handling movement and combat
  - Broadcasting state to clients
  """

  use GenServer

  alias TermProject.Game.{GameState, CombatResolver}
  alias TermProject.Game.UnitTypes
  alias TermProject.Utils.{Position, Serializer}

  @tick_interval 100 # Game loop tick interval in milliseconds

  ## Client API

  @doc """
  Starts the Game server.
  """
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %GameState{}, name: __MODULE__)
  end

  @doc """
  Spawns a unit for a player.

  ## Parameters
  - player_id: The ID of the player spawning the unit.
  - unit_type: The type of unit to spawn (e.g., :soldier).

  ## Returns
  - :ok on success
  - {:error, reason} on failure
  """
  def spawn_unit(player_id, unit_type) do
    GenServer.call(__MODULE__, {:spawn_unit, player_id, unit_type})
  end

  ## Server Callbacks

  def init(state) do
    schedule_tick()
    {:ok, state}
  end

  def handle_call({:spawn_unit, player_id, unit_type}, _from, state) do
    with {:ok, unit_module} <- get_unit_module(unit_type),
         unit <- unit_module.init(id: UUID.uuid4(), owner: player_id, position: Position.starting_position(player_id)) do
      new_state = %{state | units: [unit | state.units]}
      {:reply, :ok, new_state}
    else
      :error -> {:reply, {:error, :invalid_unit_type}, state}
    end
  end

  def handle_info(:tick, state) do
    new_state = state
    |> increment_tick()
    |> move_units()
    |> handle_combat()
    |> remove_dead_units()
    |> check_win_conditions()
    broadcast_state(new_state)
    schedule_tick()
    {:noreply, new_state}
  end

  ## Helper Functions

  defp schedule_tick() do
    Process.send_after(self(), :tick, @tick_interval)
  end

  defp increment_tick(state) do
    %{state | tick: state.tick + 1}
  end

  defp move_units(state) do
    units = Enum.map(state.units, fn unit ->
      with {:ok, unit_module} <- get_unit_module(unit.type) do
        unit_module.move(unit)
      else
        _ -> unit
      end
    end)
    %{state | units: units}
  end

  defp handle_combat(state) do
    units = CombatResolver.resolve(state.units)
    %{state | units: units}
  end

  defp remove_dead_units(state) do
    units = Enum.filter(state.units, fn unit -> unit.health > 0 end)
    %{state | units: units}
  end

  defp check_win_conditions(state) do
    # TODO: Implement win condition logic
    # - Check if a player's base has been destroyed
    # - Determine the winner and handle end-game state
    state
  end

  defp broadcast_state(state) do
    serialized_state = Serializer.serialize_state(state)
    TermProjectWeb.Endpoint.broadcast!("game:lobby", "state_update", serialized_state)
  end

  defp get_unit_module(unit_type) do
    case unit_type do
      :soldier -> {:ok, UnitTypes.Soldier}
      :archer -> {:ok, UnitTypes.Archer}
      :cavalry -> {:ok, UnitTypes.Cavalry}
      # TODO: Add other unit types here
      _ -> :error
    end
  end
end
