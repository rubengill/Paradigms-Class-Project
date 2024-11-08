defmodule TermProject.Game.LobbyManager do
  use GenServer

  # Client API

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def create_lobby(lobby_name) do
    GenServer.call(__MODULE__, {:create_lobby, lobby_name})
  end

  def list_lobbies() do
    GenServer.call(__MODULE__, :list_lobbies)
  end

  def join_lobby(lobby_name, player_id) do
    GenServer.call(__MODULE__, {:join_lobby, lobby_name, player_id})
  end

  # Server Callbacks

  def init(_) do
    # Each lobby will be represented as a map with a list of players
    {:ok, %{}}
  end

  def handle_call({:create_lobby, lobby_name}, _from, state) do
    if Map.has_key?(state, lobby_name) do
      {:reply, {:error, "Lobby already exists"}, state}
    else
      new_state = Map.put(state, lobby_name, [])
      broadcast_lobby_update()
      {:reply, :ok, new_state}
    end
  end

  def handle_call(:list_lobbies, _from, state) do
    {:reply, Map.keys(state), state}
  end

  def handle_call({:join_lobby, lobby_name, player_id}, _from, state) do
    if Map.has_key?(state, lobby_name) do
      players = Map.get(state, lobby_name)
      new_state = Map.put(state, lobby_name, [player_id | players])
      broadcast_player_joined(lobby_name, player_id)
      {:reply, :ok, new_state}
    else
      {:reply, {:error, "Lobby not found"}, state}
    end
  end

  def handle_in("create_lobby", %{"lobby_name" => lobby_name}, socket) do
    case LobbyManager.create_lobby(lobby_name) do
      :ok ->
        Phoenix.PubSub.broadcast(TermProject.PubSub, "lobby_updates", {:lobby_created, lobby_name})
        {:noreply, socket}
      {:error, reason} ->
        {:reply, {:error, reason}, socket}
    end
  end

  # Multiplay session management
  def handle_in("join_lobby", %{"lobby_name" => lobby_name, "player_id" => player_id}, socket) do
    LobbyManager.join_lobby(lobby_name, player_id)
    {:noreply, socket}
  end

  def handle_in("leave_lobby", %{"lobby_name" => lobby_name, "player_id" => player_id}, socket) do
    LobbyManager.leave_lobby(lobby_name, player_id)
    {:noreply, socket}
  end

  # Broadcasting helper functions
  defp broadcast_lobby_update() do
    Phoenix.PubSub.broadcast(TermProject.PubSub, "lobby_updates", {:lobby_update})
  end

  defp broadcast_player_joined(lobby_name, player_id) do
    Phoenix.PubSub.broadcast(TermProject.PubSub, "lobby_updates", {:player_joined, lobby_name, player_id})
  end
end
