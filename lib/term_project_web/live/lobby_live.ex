defmodule TermProjectWeb.LobbyLive do
  use TermProjectWeb, :live_view

  def mount(params, _session, socket) do
    username = params["username"]

    if connected?(socket), do: Phoenix.PubSub.subscribe(TermProject.PubSub, "lobbies")
    {:ok, assign(socket, lobbies: TermProject.Game.LobbyServer.list_lobbies(), username: username)}
  end

  def handle_event("create_lobby", %{"max_players" => max_players}, socket) do
    username = socket.assigns.username
    {:ok, lobby_id} = TermProject.Game.LobbyServer.create_lobby(String.to_integer(max_players))
    :ok = TermProject.Game.LobbyServer.join_lobby(lobby_id, username)
    {:noreply, redirect(socket, to: ~p"/lobby/#{lobby_id}?username=#{URI.encode(username)}")}
  end

  def handle_event("matchmaking", _params, socket) do
    username = socket.assigns.username

    case TermProject.Game.LobbyServer.find_and_join_lobby(username) do
      {:ok, lobby_id} ->
        {:noreply, redirect(socket, to: ~p"/lobby/#{lobby_id}?username=#{URI.encode(username)}")}
      {:error, :no_available_lobby} ->
        max_players = 4  # Default value
        {:ok, lobby_id} = TermProject.Game.LobbyServer.create_lobby(max_players)
        :ok = TermProject.Game.LobbyServer.join_lobby(lobby_id, username)
        {:noreply, redirect(socket, to: ~p"/lobby/#{lobby_id}?username=#{URI.encode(username)}")}
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Matchmaking failed: #{inspect(reason)}")}
    end
  end

  def handle_info(:lobby_updated, socket) do
    {:noreply, assign(socket, lobbies: TermProject.Game.LobbyServer.list_lobbies())}
  end
end
