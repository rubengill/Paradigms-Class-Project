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
  @attack_cooldown 1000  # ms between attacks

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
      case :global.whereis_name({:global, {:game_server, lobby_id}}) do
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
  def handle_info(:tick, %{game_state: game_state, lobby_id: lobby_id} = state) do
    updated_game_state = game_state
      |> GameState.auto_update_resources()
      |> update_unit_positions(lobby_id)
      |> update_combat()

    broadcast_game_update(lobby_id, updated_game_state)
    {:noreply, %{state | game_state: updated_game_state}}
  end

  @impl true
  def handle_info(unknown_message, state) do
    IO.warn("Received unknown message in Game server: #{inspect(unknown_message)}")
    {:noreply, state}
  end

  @impl true
  def handle_info({:combat_event, message}, state) do
    # Broadcast the combat event and update game state
    broadcast_combat_event(state.lobby_id, message)
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

  defp update_unit_positions(game_state, lobby_id) do
    # Track state through unit updates
    Enum.reduce(game_state.units, game_state, fn unit, current_state ->
      {updated_unit, updated_state} = process_unit(unit, current_state, lobby_id)

      %{updated_state |
        units: replace_unit(updated_state.units, updated_unit)
      }
    end)
  end

  defp process_unit(unit, game_state, lobby_id) do
    target = find_target(unit, game_state)

    case target do
      {:unit, enemy} ->
        if check_range(unit, enemy.position, unit.range) do
          {updated_unit, updated_game_state} = attack_unit(unit, enemy, game_state, lobby_id)
          # Return both unit and game state updates
          {updated_unit, updated_game_state}
        else
          {move_unit(unit, game_state), game_state}
        end

      {:base, base_pos} ->
        if check_range(unit, base_pos, unit.range) do
          attack_base(unit, game_state, lobby_id)
        else
          {move_unit(unit, game_state), game_state}
        end

      _ -> {move_unit(unit, game_state), game_state}
    end
  end

  defp check_range(unit, target_pos, range) do
    dx = target_pos.x - unit.position.x
    dy = target_pos.y - unit.position.y
    :math.sqrt(dx * dx + dy * dy) <= range
  end

  defp attack_unit(attacker, target, game_state, lobby_id) do
    if can_attack?(attacker) do
      current_time = System.monotonic_time(:millisecond)

      # Calculate new health
      new_health = target.health - attacker.damage

      # Create updated target unit
      updated_target = %{target | health: new_health}

      # Update game state and remove dead units
      updated_game_state = %{game_state |
        units: game_state.units
          |> Enum.map(fn unit ->
            cond do
              unit.id == target.id && new_health <= 0 -> nil  # Remove dead unit
              unit.id == target.id -> updated_target  # Update damaged unit
              true -> unit  # Keep other units unchanged
            end
          end)
          |> Enum.reject(&is_nil/1)  # Remove nil (dead) units
      }

      # Broadcast combat message
      message = if new_health <= 0 do
        "#{attacker.type} killed #{target.type}!"
      else
        "#{attacker.type} deals #{attacker.damage} damage to #{target.type}! (Health: #{new_health})"
      end
      broadcast_combat_event(lobby_id, message)

      # Return updated attacker and game state
      {%{attacker | last_attack: current_time}, updated_game_state}
    else
      {attacker, game_state}
    end
  end

  defp combat_message(attacker, target, new_health) do
    if new_health <= 0 do
      "#{attacker.type} killed #{target.type}!"
    else
      "#{attacker.type} deals #{attacker.damage} damage to #{target.type}! (Health: #{new_health})"
    end
  end

  defp attack_base(unit, game_state, lobby_id) do
    current_time = System.monotonic_time(:millisecond)
    enemy_base_id = if unit.owner == 1, do: 2, else: 1
    damage = unit.damage

    if can_attack?(unit) do
      broadcast_combat_event(lobby_id, "#{unit.type} deals #{damage} damage to base!")

      updated_bases = Map.update!(game_state.bases, enemy_base_id, fn base ->
        %{base | health: base.health - damage}
      end)

      updated_unit = %{unit | last_attack: current_time}
      updated_game_state = %{game_state | bases: updated_bases}

      {updated_unit, updated_game_state}
    else
      {unit, game_state}
    end
  end

  defp broadcast_combat_event(lobby_id, message) do
    Phoenix.PubSub.broadcast(
      TermProject.PubSub,
      "game:#{lobby_id}",
      {:combat_event, message}
    )
  end

  defp can_attack?(unit) do
    current_time = System.monotonic_time(:millisecond)
    is_nil(unit.last_attack) ||
      current_time - unit.last_attack >= @attack_cooldown
  end

  defp move_unit(unit, game_state) do
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
  end

  defp find_target(unit, game_state) do
    enemy_base_id = if unit.owner == 1, do: 2, else: 1
    base_pos = game_state.bases[enemy_base_id].position

    # Find closest enemy unit by distance and different owner
    closest_enemy = game_state.units
      |> Enum.filter(fn other ->
        other.owner != unit.owner && other.health > 0 && other.id != unit.id
      end)
      |> Enum.min_by(fn enemy ->
        dx = enemy.position.x - unit.position.x
        dy = enemy.position.y - unit.position.y
        :math.sqrt(dx * dx + dy * dy)
      end, fn -> nil end)

    case closest_enemy do
      nil -> {:base, base_pos}
      enemy -> {:unit, enemy}
    end
  end

  defp update_combat(game_state) do
    # Remove any units with health <= 0
    %{game_state |
      units: Enum.filter(game_state.units, fn unit ->
        unit.health > 0
      end)
    }
  end

  defp replace_unit(units, updated_unit) do
    units
    |> Enum.map(fn unit ->
      cond do
        unit.id == updated_unit.id && updated_unit.health <= 0 -> nil
        unit.id == updated_unit.id -> updated_unit
        true -> unit
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp handle_error({:error, _reason} = error), do: error
end
