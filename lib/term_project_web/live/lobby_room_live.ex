defmodule TermProjectWeb.LobbyRoomLive do
  use TermProjectWeb, :live_view

  def mount(%{"id" => lobby_id, "username" => username}, _session, socket) do
    lobby_id = String.to_integer(lobby_id)
    case TermProject.Game.LobbyServer.get_lobby(lobby_id) do
      {:ok, lobby} ->
        if connected?(socket), do: Phoenix.PubSub.subscribe(TermProject.PubSub, "lobby:chat:#{lobby_id}")

        # Automatically join the user if not already in the lobby
        unless Map.has_key?(lobby.players, username) do
          case TermProject.Game.LobbyServer.join_lobby(lobby_id, username) do
            :ok -> :ok
            {:error, :lobby_full} ->
              socket = put_flash(socket, :error, "Lobby is full") |> redirect(to: "/")
              {:ok, socket}
            {:error, _} ->
              socket = put_flash(socket, :error, "Could not join lobby") |> redirect(to: "/")
              {:ok, socket}
          end
        end

        # Fetch the updated lobby
        {:ok, updated_lobby} = TermProject.Game.LobbyServer.get_lobby(lobby_id)
        {:ok, assign(socket, lobby: updated_lobby, username: username, ready: false, messages: [])}

      {:error, _} ->
        socket = assign(socket, :error, "Unable to find lobby.") |> redirect(to: "/login")
        {:ok, socket}
    end
  end

  def handle_event("join_lobby", %{"username" => username}, socket) do
    lobby_id = socket.assigns.lobby.id
    case TermProject.Game.LobbyServer.join_lobby(lobby_id, username) do
      :ok ->
        {:noreply, assign(socket, username: username)}
      {:error, :lobby_full} ->
        {:noreply, put_flash(socket, :error, "Lobby is full")}
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not join lobby")}
    end
  end

  def handle_event("toggle_ready", _params, socket) do
    lobby_id = socket.assigns.lobby.id
    username = socket.assigns.username
    ready = !socket.assigns.ready
    case TermProject.Game.LobbyServer.set_ready_status(lobby_id, username, ready) do
      :ok ->
        {:noreply, assign(socket, ready: ready)}
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not update ready status")}
    end
  end

  # Add close_lobby handler
  def handle_event("close_lobby", _params, socket) do
    lobby_id = socket.assigns.lobby.id
    username = socket.assigns.username
    case TermProject.Game.LobbyServer.close_lobby(lobby_id, username) do
      :ok ->
        {:noreply, push_navigate(socket, to: ~p"/")}
      {:error, :not_host} ->
        {:noreply, put_flash(socket, :error, "Only the host can close the lobby")}
      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not close lobby")}
    end
  end

  def handle_event("send_message", %{"message" => msg}, socket) do
    user = socket.assigns.username || "Anonymous"
    message = %{user: user, body: msg}
    Phoenix.PubSub.broadcast(TermProject.PubSub, "lobby:chat:#{socket.assigns.lobby.id}", message)
    {:noreply, socket}
  end

  # Fix handle_info for lobby_updated message
  def handle_info(:lobby_updated, %{assigns: %{lobby: %{id: id}}} = socket) do
    case TermProject.Game.LobbyServer.get_lobby(id) do
      {:ok, updated_lobby} ->
        {:noreply, assign(socket, lobby: updated_lobby)}
      {:error, _} ->
        {:noreply, push_navigate(socket, to: ~p"/")}
    end
  end

  # Add handler for lobby_closed message
  def handle_info(:lobby_closed, socket) do
    {:noreply, socket
      |> put_flash(:info, "Lobby was closed by the host")
      |> push_navigate(to: ~p"/")}
  end


  def handle_info(%{body: body, user: user}, socket) do
    message = %{user: user, body: body}
    messages = [message | socket.assigns.messages]
    {:noreply, assign(socket, messages: messages)}
  end
end
