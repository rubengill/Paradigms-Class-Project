defmodule TermProjectWeb.LobbyLive do
  use Phoenix.LiveView
  alias TermProject.Game.LobbyManager

  def mount(_params, _session, socket) do
    if connected?(socket), do: subscribe_to_lobby_updates()
    lobbies = LobbyManager.list_lobbies()
    {:ok, assign(socket, lobbies: lobbies, lobby_name: "", player_id: "")}
  end

  def handle_event("create_lobby", %{"lobby_name" => lobby_name}, socket) do
    case LobbyManager.create_lobby(lobby_name) do
      :ok ->
        {:noreply, assign(socket, lobby_name: "")}
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, reason)}
    end
  end

  def handle_event("join_lobby", %{"lobby_name" => lobby_name, "player_id" => player_id}, socket) do
    case LobbyManager.join_lobby(lobby_name, player_id) do
      :ok ->
        {:noreply, assign(socket, lobby_name: "", player_id: "")}
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, reason)}
    end
  end

  def handle_info({:lobby_update}, socket) do
    lobbies = LobbyManager.list_lobbies()
    {:noreply, assign(socket, lobbies: lobbies)}
  end

  def handle_info({:player_joined, lobby_name, player_id}, socket) do
    # Handle logic if you want to notify users of a new player joining a lobby
    {:noreply, socket}
  end

  defp subscribe_to_lobby_updates do
    Phoenix.PubSub.subscribe(TermProject.PubSub, "lobby_updates")
  end
end
