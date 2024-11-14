defmodule TermProject.Game.LobbyManager do
  use GenServer

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def create_lobby(lobby_name) do
    GenServer.cast(__MODULE__, {:create_lobby, lobby_name})
  end

  def list_lobbies() do
    GenServer.call(__MODULE__, :list_lobbies)
  end

  # Server Callbacks

  def init(_) do
    {:ok, %{}}
  end

  def handle_cast({:create_lobby, lobby_name}, state) do
    new_state = Map.put(state, lobby_name, [])
    IO.inspect(new_state, label: "Updated state after creating lobby")
    broadcast_new_lobby(lobby_name)
    {:noreply, new_state}
  end

  def handle_call(:list_lobbies, _from, state) do
    {:reply, Map.keys(state), state}
  end

  defp broadcast_new_lobby(lobby_name) do
    Phoenix.PubSub.broadcast(TermProject.PubSub, "lobby_updates", {:new_lobby, lobby_name})
  end
end
