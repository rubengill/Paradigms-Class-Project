defmodule TermProject.Game.LobbyServer do
  use GenServer

  # Client API

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def create_lobby(max_players) do
    GenServer.call(__MODULE__, {:create_lobby, max_players})
  end

  def list_lobbies do
    case :ets.info(:lobbies) do
      :undefined -> []
      _ ->
        :ets.match_object(:lobbies, {:_, :_})
        |> Enum.map(fn {_, lobby} -> lobby end)
    end
  end

  def join_lobby(lobby_id, username) do
    GenServer.call(__MODULE__, {:join_lobby, lobby_id, username})
  end

  def set_ready_status(lobby_id, username, ready_status) do
    GenServer.call(__MODULE__, {:set_ready_status, lobby_id, username, ready_status})
  end

  def get_lobby(lobby_id) do
    GenServer.call(__MODULE__, {:get_lobby, lobby_id})
  end

  def close_lobby(lobby_id, username) do
    GenServer.call(__MODULE__, {:close_lobby, lobby_id, username})
  end

  def find_and_join_lobby(username) do
    GenServer.call(__MODULE__, {:find_and_join_lobby, username})
  end

  # Server Callbacks

  def init(_state) do
    :ets.new(:lobbies, [:set, :named_table, :public])
    {:ok, %{}}
  end

  def handle_call({:create_lobby, max_players}, _from, state) do
    lobby_id = :erlang.unique_integer([:positive])
    lobby = %{
      id: lobby_id,
      max_players: max_players,
      players: %{},
      host: nil  # Will be set when first player joins
    }
    :ets.insert(:lobbies, {lobby_id, lobby})
    Phoenix.PubSub.broadcast(TermProject.PubSub, "lobbies", :lobby_updated)
    {:reply, {:ok, lobby_id}, state}
  end

  def handle_call({:join_lobby, lobby_id, username}, _from, state) do
    result = join_lobby_internal(lobby_id, username)
    case result do
      {:ok, _} -> {:reply, :ok, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
    case :ets.lookup(:lobbies, lobby_id) do
      [{^lobby_id, lobby}] ->
        if map_size(lobby.players) < lobby.max_players do
          updated_players = Map.put(lobby.players, username, %{ready: false})
          # Set host if first player
          host = if map_size(lobby.players) == 0, do: username, else: lobby.host
          updated_lobby = %{lobby | players: updated_players, host: host}
          :ets.insert(:lobbies, {lobby_id, updated_lobby})
          Phoenix.PubSub.broadcast(TermProject.PubSub, "lobby:#{lobby_id}", :lobby_updated)
          {:reply, :ok, state}
        else
          {:reply, {:error, :lobby_full}, state}
        end

      [] ->
        {:reply, {:error, :lobby_not_found}, state}
    end
  end

  def handle_call({:set_ready_status, lobby_id, username, ready_status}, _from, state) do
    case :ets.lookup(:lobbies, lobby_id) do
      [{^lobby_id, lobby}] ->
        if Map.has_key?(lobby.players, username) do
          updated_players = Map.update!(lobby.players, username, fn player ->
            %{player | ready: ready_status}
          end)
          updated_lobby = %{lobby | players: updated_players}
          :ets.insert(:lobbies, {lobby_id, updated_lobby})
          Phoenix.PubSub.broadcast(TermProject.PubSub, "lobby:#{lobby_id}", :lobby_updated)
          {:reply, :ok, state}
        else
          {:reply, {:error, :player_not_found}, state}
        end

      [] ->
        {:reply, {:error, :lobby_not_found}, state}
    end
  end

  def handle_call({:get_lobby, lobby_id}, _from, state) do
    case :ets.lookup(:lobbies, lobby_id) do
      [{^lobby_id, lobby}] ->
        {:reply, {:ok, lobby}, state}

      [] ->
        {:reply, {:error, :lobby_not_found}, state}
    end
  end

  def handle_call({:close_lobby, lobby_id, username}, _from, state) do
    case :ets.lookup(:lobbies, lobby_id) do
      [{^lobby_id, lobby}] ->
        if lobby.host == username do
          :ets.delete(:lobbies, lobby_id)
          Phoenix.PubSub.broadcast(TermProject.PubSub, "lobbies", :lobby_updated)
          Phoenix.PubSub.broadcast(TermProject.PubSub, "lobby:#{lobby_id}", :lobby_closed)
          {:reply, :ok, state}
        else
          {:reply, {:error, :not_host}, state}
        end

      [] ->
        {:reply, {:error, :lobby_not_found}, state}
    end
  end

  def handle_call({:find_and_join_lobby, username}, _from, state) do
    available_lobbies =
      :ets.tab2list(:lobbies)
      |> Enum.map(fn {_id, lobby} -> lobby end)
      |> Enum.filter(fn lobby ->
        map_size(lobby.players) < lobby.max_players
      end)

    case Enum.random(available_lobbies) do
      nil ->
        {:reply, {:error, :no_available_lobby}, state}

      lobby ->
        lobby_id = lobby.id
        case join_lobby_internal(lobby_id, username) do
          {:ok, _lobby_id} ->
            {:reply, {:ok, lobby_id}, state}
          {:error, reason} ->
            {:reply, {:error, reason}, state}
        end
    end
  end

  # Helper function to handle joining a lobby internally
  defp join_lobby_internal(lobby_id, username) do
    case :ets.lookup(:lobbies, lobby_id) do
      [{^lobby_id, lobby}] ->
        if Map.has_key?(lobby.players, username) do
          {:error, :already_in_lobby}
        else
          if map_size(lobby.players) < lobby.max_players do
            updated_players = Map.put(lobby.players, username, %{ready: false})
            host = if map_size(lobby.players) == 0, do: username, else: lobby.host
            updated_lobby = %{lobby | players: updated_players, host: host}
            :ets.insert(:lobbies, {lobby_id, updated_lobby})
            Phoenix.PubSub.broadcast(TermProject.PubSub, "lobby:#{lobby_id}", :lobby_updated)
            {:ok, lobby_id}
          else
            {:error, :lobby_full}
          end
        end

      [] ->
        {:error, :lobby_not_found}
    end
  end

end
