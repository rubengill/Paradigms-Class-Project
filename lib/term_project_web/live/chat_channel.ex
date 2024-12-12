defmodule TermProjectWeb.ChatChannel do
  use Phoenix.Channel
  def join("lobby:chat:" <> lobby_id, _payload, socket) do
    Phoenix.PubSub.subscribe(TermProject.PubSub, "lobby:chat:#{lobby_id}")
    {:ok, assign(socket, lobby_id: lobby_id)}
  end

  def handle_in("message:new", %{"message" => message} = payload, socket) do
    user = socket.assigns.username || "Anonymous"
    message_data = %{user: user, body: message}
    # Broadcast the message to all subscribers of this lobby's chat
    Phoenix.PubSub.broadcast(TermProject.PubSub, "lobby:chat:#{socket.assigns.lobby_id}", message_data)
    {:noreply, socket}
  end
end
