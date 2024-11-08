defmodule TermProjectWeb.GameChannel do
  @moduledoc """
  Handles communication between the server and clients.
  """

  use Phoenix.Channel

  alias TermProject.Game.LobbyManager

  def join("game:lobby", _message, socket) do
    player_id = assign_player_id(socket)
    {:ok, %{player_id: player_id}, assign(socket, :player_id, player_id)}
  end

  def handle_in("spawn_unit", %{"unit_type" => unit_type}, socket) do
    player_id = socket.assigns.player_id
    case Game.spawn_unit(player_id, String.to_existing_atom(unit_type)) do
      :ok -> {:noreply, socket}
      {:error, reason} -> {:reply, {:error, reason}, socket}
    end
  end

  # TODO: Handle other incoming messages (e.g., resource management, chat messages)
  def handle_in("chat_message", %{"message" => message}, socket) do
    player_id = socket.assigns.player_id
    broadcast!(socket, "chat_message", %{player_id: player_id, message: message})
    {:noreply, socket}
  end

  def handle_in("collect_resource", %{"resource_type" => resource_type}, socket) do
    player_id = socket.assigns.player_id
    case Game.collect_resource(player_id, String.to_existing_atom(resource_type)) do
      :ok -> {:noreply, socket}
      {:error, reason} -> {:reply, {:error, reason}, socket}
    end
  end

  # Helper function to assign player IDs
  defp assign_player_id(_socket) do
    # TODO: Implement proper player identification and authentication
    # :erlang.phash2(socket.transport_pid)
    UUID.uuid4()  # Generates a unique player ID
  end
end
