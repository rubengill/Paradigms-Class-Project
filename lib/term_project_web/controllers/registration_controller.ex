defmodule TermProjectWeb.RegistrationController do
  use TermProjectWeb, :controller
  alias TermProject.Accounts

  # Display the registration form
  def new(conn, _params) do
    render(conn, "register.html", layout: false)
  end

  # Handle the registration form submission
  def create(conn, %{"user" => %{"username" => username, "password" => password}}) do
    case Accounts.register_user(%{username: username, password: password}) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Registration successful. Please log in.")
        |> redirect(to: ~p"/login")

      {:error, changeset} ->
        IO.inspect(changeset.errors, label: "Changeset Errors")
        conn
        |> put_flash(:error, "Failed to register.")
        |> render("register.html", changeset: changeset)
    end
  end
end
