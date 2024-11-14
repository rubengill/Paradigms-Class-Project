defmodule TermProjectWeb.LobbyController do
  use TermProjectWeb, :controller
  alias TermProject.Game.LobbyManager
  alias TermProjectWeb.Router, as: Routes

  # Display the list of lobbies and a form to create a new lobby
  def index(conn, _params) do
    lobbies = LobbyManager.list_lobbies()
    render(conn, "lobby.html", lobbies: lobbies, lobby_name: "")
  end

  # Handle lobby creation from the form submission
  def create(conn, %{"lobby_name" => lobby_name}) do
    LobbyManager.create_lobby(lobby_name)
    lobbies = LobbyManager.list_lobbies()
    IO.inspect(lobbies, label: "Lobbies after creation")
    conn
    |> put_flash(:info, "Lobby created successfully.")
    |> redirect(to: ~p"/lobby")
  end

  # Handle joining a lobby
  def join(conn, %{"lobby_name" => lobby_name}) do
    # Add logic for joining the lobby if necessary
    conn
    |> put_flash(:info, "Joined lobby #{lobby_name}.")
    |> redirect(to: ~p"/lobby")
  end
end
