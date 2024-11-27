defmodule TermProjectWeb.LobbyLive do
  use TermProjectWeb, :live_view

  def mount(params, _session, socket) do
    username = params["username"] || socket.assigns[:username]

    if is_nil(username) do
      # Redirect or prompt the user to enter their username
      {:ok, redirect(socket, to: "/login")}
    else
      if connected?(socket), do: Phoenix.PubSub.subscribe(TermProject.PubSub, "lobbies")
      {:ok, assign(socket, lobbies: TermProject.Game.LobbyServer.list_lobbies(), username: username, is_private: false)}
    end
  end

  def handle_event("create_lobby", %{"max_players" => max_players, "password" => password, "is_private" => is_private, "username" => username}, socket) do
    password = if is_private == "true", do: password, else: nil  # Treat empty password as nil
    {:ok, lobby_id} = TermProject.Game.LobbyServer.create_lobby(String.to_integer(max_players), password)

    case TermProject.Game.LobbyServer.join_lobby(lobby_id, username, password) do
      :ok ->
        {:noreply, redirect(socket, to: ~p"/lobby/#{lobby_id}?username=#{URI.encode(username)}")}

      {:error, :already_in_lobby} ->
        # Since the user is already in the lobby, proceed to redirect
        {:noreply, redirect(socket, to: ~p"/lobby/#{lobby_id}?username=#{URI.encode(username)}")}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Could not join lobby: #{inspect(reason)}")
         |> redirect(to: "/")}
    end
  end

  def handle_event("toggle_private", %{"is_private" => "true"}, socket) do
    {:noreply, assign(socket, is_private: true)}
  end

  def handle_event("toggle_private", _params, socket) do
    {:noreply, assign(socket, is_private: false)}
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
