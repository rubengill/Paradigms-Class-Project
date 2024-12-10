defmodule TermProject.Game do
  @moduledoc """
  Handles the core game logic and state for each game instance.

  Responsibilities:
  - Manages game state using a `GenServer`.
  - Synchronizes actions with the server (using a mock server for now).
  - Processes game logic on each tick.
  """

  use GenServer

  alias TermProject.GameState
  alias TermProject.MockServer # Replace with the real server module when available

  @tick_duration 100 # Tick duration in milliseconds

  # Public API

  @doc """
  Starts a new game instance.

  ## Parameters
  - `match_id`: A unique identifier for the match.

  ## Returns
  - `{:ok, pid}` on success.
  """
  def start_link(match_id) do
    GenServer.start_link(__MODULE__, %{match_id: match_id}, name: via_tuple(match_id))
  end

  @doc """
  Spawns a new unit (e.g., Archer, Knight) in the game.

  ## Parameters
  - `match_id`: The unique match ID.
  - `unit_type`: The type of unit to spawn.

  ## Returns
  - `:ok` on success.
  """
  def spawn_unit(match_id, unit_type) do
    GenServer.call(via_tuple(match_id), {:spawn_unit, unit_type})
  end

  # GenServer Callbacks

  @impl true
  def init(state) do
    # Initialize game state and server connection
    initial_state = GameState.new()
    server = MockServer # Replace with the real server module

    # Start the game loop
    send(self(), :tick)

    {:ok, %{state | game_state: initial_state, server: server}}
  end

  @impl true
  def handle_call({:spawn_unit, unit_type}, _from, %{game_state: state} = s) do
    # Add unit to the game state
    updated_state = GameState.apply_action(state, {:create_unit, unit_type})

    {:reply, :ok, %{s | game_state: updated_state}}
  end

  @impl true
  def handle_info(:tick, %{game_state: state, server: server, match_id: match_id} = s) do
    # Synchronize with the server
    {opponent_actions, confirmed_tick} = sync_with_server(server, match_id, state.tick)

    # Log the synchronization for debugging
    IO.inspect(opponent_actions, label: "Opponent Actions")
    IO.puts("Server confirmed tick: #{confirmed_tick}")

    # Apply opponent actions
    updated_state = GameState.apply_opponent_actions(state, opponent_actions)

    # Process local tick logic
    updated_state = process_local_tick(updated_state)

    # Send local actions to the server
    local_actions = generate_local_actions(updated_state)
    send_actions_to_server(server, match_id, updated_state.tick, local_actions)

    # Schedule the next tick
    Process.send_after(self(), :tick, @tick_duration)

    {:noreply, %{s | game_state: %{updated_state | tick: updated_state.tick + 1}}}
  end

  # Private Helpers

  defp process_local_tick(state) do
    # Placeholder: Add unit movement, combat, or resource updates here

    # Update resources
    GameState.auto_update_resources(state)

    state
  end

  defp generate_local_actions(_state) do
    # Placeholder: Generate actions for this tick (e.g., spawn units)
    []
  end

  defp send_actions_to_server(server, match_id, tick, actions) do
    # Notify the server about local actions
    server.send_actions(match_id, tick, actions)
  end

  defp sync_with_server(server, match_id, tick) do
    # Get opponent actions from the server
    server.get_opponent_actions(match_id, tick)
  end

  defp via_tuple(match_id) do
    {:via, Registry, {TermProject.GameRegistry, match_id}}
  end
end
