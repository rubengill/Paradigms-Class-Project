defmodule TermProject.Game do
  @moduledoc """
  Handles the core game logic and state for each game instance.
  Uses PubSub for state synchronization through lobby channels.
  """

  use GenServer

  alias TermProject.GameState
  alias TermProject.Game.LobbyServer
  alias Phoenix.PubSub

  @tick_rate 100
  @unit_speed 5  # pixels per tick

  # Public API

  @doc """
  Starts a new game instance for a specific lobby_id.
  """
  def start_link(%{lobby_id: lobby_id, players: players}) do
    GenServer.start_link(__MODULE__, %{lobby_id: lobby_id, players: players},
      name: {:global, {:game_server, lobby_id}})
  end

  @doc """
  Spawns a unit for a specific player in the game.
  Broadcasts the update through PubSub to sync all players.
  """
  def spawn_unit(lobby_id, unit_type, player_id) do
    GenServer.call({:global, {:game_server, lobby_id}}, {:spawn_unit, unit_type, player_id})
  end

  @doc """
  Retrieves the current game state for a lobby.
  Used by clients to sync their local state.
  """
  def get_state(lobby_id) do
    try do
      case :global.whereis_name({:game_server, lobby_id}) do
        :undefined ->
          # No game process exists
          {:error, :game_not_found}

        pid when is_pid(pid) ->
          # Call with timeout
          case GenServer.call(pid, :get_state, 5000) do
            game_state -> {:ok, game_state}
          end
      end
    catch
      :exit, _ -> {:error, :game_not_available}
    end
  end

  # GenServer Callbacks

  # In game.ex
  @impl true
  def init(%{lobby_id: lobby_id, players: player_mapping}) do
    initial_state = %{
      lobby_id: lobby_id,
      players: player_mapping,
      game_state: %TermProject.GameState{
        tick: 0,
        players: player_mapping,
        bases: initialize_bases(player_mapping),
        resources: initialize_resources()
      }
    }

    # Subscribe to the game's PubSub topic
    PubSub.subscribe(TermProject.PubSub, "game:#{lobby_id}")
    Process.flag(:trap_exit, true)
    :timer.send_interval(@tick_rate, :tick)

    {:ok, initial_state}
  end

  @impl true
  def handle_call({:spawn_unit, unit_type, player_id}, _from, state) do
    case GameState.apply_action(state.game_state, {:create_unit, unit_type, player_id}) do  # Add player_id
      {:ok, updated_game_state} ->
        broadcast_game_update(state.lobby_id, updated_game_state)
        {:reply, :ok, %{state | game_state: updated_game_state}}

      {:error, reason} = error ->
        {:reply, error, state}
    end
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state.game_state, state}
  end

  @impl true
  def handle_info({:game_state_update, updated_game_state}, state) do
    # Simply update the state with the new game state
    {:noreply, %{state | game_state: updated_game_state}}
  end

  @impl true
  def handle_info({:player_action, _player_id, action}, state) do
    updated_game_state = GameState.apply_action(state.game_state, action)
    broadcast_game_update(state.lobby_id, updated_game_state)
    {:noreply, %{state | game_state: updated_game_state}}
  end

  @impl true
  def handle_info(:game_started, state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(:game_ended, state) do
    {:stop, :normal, state}
  end

  @impl true
  def handle_info(:tick, %{game_state: game_state} = state) do
    updated_game_state = game_state
      |> TermProject.GameState.auto_update_resources()
      |> update_unit_positions()

    broadcast_game_update(state.lobby_id, updated_game_state)
    {:noreply, %{state | game_state: updated_game_state}}
  end

  @impl true
  def handle_info(unknown_message, state) do
    IO.warn("Received unknown message in Game server: #{inspect(unknown_message)}")
    {:noreply, state}
  end

  # Private Helpers
  defp broadcast_game_update(lobby_id, game_state) do
    Phoenix.PubSub.broadcast(
      TermProject.PubSub,
      "game:#{lobby_id}",
      {:game_state_update, game_state}
    )
  end

  defp initialize_resources do
    %{
      1 => %{
        workers: %{unused: 0, wood: 3, stone: 3, iron: 3},
        amounts: %{wood: 200, stone: 100, iron: 20}
      },
      2 => %{
        workers: %{unused: 0, wood: 3, stone: 3, iron: 3},
        amounts: %{wood: 200, stone: 100, iron: 20}
      }
    }
  end

  defp initialize_bases(player_mapping) do
    Enum.reduce(player_mapping, %{}, fn {player_id, _name}, acc ->
      Map.put(acc, player_id, %{
        position: get_base_position(player_id),
        health: 1000
      })
    end)
  end

  defp get_base_position(1), do: %{x: 0, y: 300.0}
  defp get_base_position(2), do: %{x: 1000, y: 300.0}

  defp update_unit_positions(game_state) do
    updated_units = Enum.map(game_state.units, fn unit ->
      # Get enemy base position
      target_base_id = if unit.owner == 1, do: 2, else: 1
      target_pos = game_state.bases[target_base_id].position

      # Calculate direction vector
      dx = target_pos.x - unit.position.x
      dy = target_pos.y - unit.position.y

      # Normalize and scale by speed
      distance = :math.sqrt(dx * dx + dy * dy)
      if distance > 0 do
        new_x = unit.position.x + (dx / distance) * @unit_speed
        new_y = unit.position.y + (dy / distance) * @unit_speed

        %{unit | position: %{x: new_x, y: new_y}}
      else
        unit
      end
    end)

    %{game_state | units: updated_units}
  end
end
