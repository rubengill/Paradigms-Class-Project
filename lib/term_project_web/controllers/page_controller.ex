defmodule TermProjectWeb.PageController do
  use TermProjectWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def login(conn, _params) do
    # Set up any necessary data here, like an empty changeset if using Ecto
    render(conn, :login, layout: false)
  end

  def register(conn, _params) do
    # Set up any necessary data here, like an empty changeset if using Ecto
    render(conn, :register, layout: false)
  end

  def create_session(conn, %{"session" => session_params}) do
    # Handle login logic here, e.g., authenticate user
    case Accounts.authenticate_user(session_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Logged in successfully.")
        |> redirect(to: Routes.page_path(conn, :home))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid credentials.")
        |> render(:login, layout: false)
    end
  end

  def create_registration(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Registration successful. Please log in.")
        |> redirect(to: Routes.page_path(conn, :login))

      {:error, changeset} ->
        render(conn, :register, changeset: changeset, layout: false)
    end
  end
end
