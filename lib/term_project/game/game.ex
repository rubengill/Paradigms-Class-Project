defmodule TermProject.Game do
  use GenServer

  alias TermProject.GameState
  alias TermProject.MockServer # Replace with real server module when available

  @tick_duration 100 # Tick duration in milliseconds

  # Public API

  @doc """
  Starts a new game instance.
  """
  def start_link(match_id) do
    GenServer.start_link(__MODULE__, %{match_id: match_id}, name: via_tuple(match_id))
  end

  @doc """
  Spawns a new unit (e.g., Archer, Knight) in the game.
  """
  def spawn_unit(match_id, unit_type) do
    GenServer.call(via_tuple(match_id), {:spawn_unit, unit_type})
  end

  # Callbacks

  @impl true
  def init(state) do
    # Initialize game state
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
    # 1. Synchronize with the server
    {opponent_actions, confirmed_tick} = sync_with_server(server, match_id, state.tick)

    # 2. Apply opponent actions
    updated_state = GameState.apply_opponent_actions(state, opponent_actions)

    # 3. Process local tick logic
    updated_state = process_local_tick(updated_state)

    # 4. Send local actions to the server
    local_actions = generate_local_actions(updated_state)
    send_actions_to_server(server, match_id, updated_state.tick, local_actions)

    # 5. Schedule the next tick
    Process.send_after(self(), :tick, @tick_duration)

    {:noreply, %{s | game_state: %{updated_state | tick: updated_state.tick + 1}}}
  end

  # Private Helpers

  defp process_local_tick(state) do
    # Placeholder: Add unit movement, combat, or resource updates here
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
