defmodule TermProjectWeb.SessionController do
  use TermProjectWeb, :controller
  alias TermProject.Accounts

  # Display the login form
  def new(conn, _params) do
    render(conn, "login.html", layout: false)
  end

  # Handle the login form submission
  def create(conn, %{"user" => %{"username" => username, "password" => password}}) do
    case Accounts.authenticate_user(username, password) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Logged in successfully.")
        |> redirect(to: ~p"/lobby")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid username or password.")
        |> render(:login, layout: false)
    end
  end

  # Logout action
  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: ~p"/login")
  end
end
