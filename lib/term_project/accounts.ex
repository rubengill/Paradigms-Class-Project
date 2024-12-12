defmodule TermProject.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias TermProject.Repo

  alias TermProject.Accounts.LoginUser

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(LoginUser)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(LoginUser, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %LoginUser{}
    |> LoginUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%LoginUser{} = user, attrs) do
    user
    |> LoginUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%LoginUser{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%LoginUser{} = user, attrs \\ %{}) do
    LoginUser.changeset(user, attrs)
  end

  def authenticate_user(email, password) do
  user = Repo.get_by(LoginUser, email: email)

  cond do
    user && Bcrypt.verify_pass(password, user.password_hash) ->
      {:ok, user}

    true ->
      {:error, :unauthorized}
  end
end

def get_user(id) do
  Repo.get(LoginUser, id)
end

def create_or_update_user(%{email: email} = attrs) do
  case Repo.get_by(LoginUser, email: email) do
    nil ->
      IO.puts("No existing user found. Creating a new user.")
      IO.inspect(attrs, label: "Attributes for New User")

      changeset = LoginUser.changeset(%LoginUser{}, attrs)
      IO.inspect(changeset, label: "Create Changeset")
      IO.puts("LOOK HERE FOR CHANGESET ERRORS")
      IO.inspect(changeset.errors)
      IO.puts("reached here")
      case Repo.insert(changeset) do
        {:ok, user} ->
          IO.puts("User created successfully: #{inspect(user)}")
          {:ok, user}

        {:error, changeset} ->
          IO.puts("Failed to create user.")
          IO.inspect(changeset.errors, label: "Changeset Errors")
          {:error, changeset}
      end

    user ->
      IO.puts("Existing user found. Updating user.")
      IO.inspect(user, label: "Existing User")

      changeset = LoginUser.changeset(user, attrs)
      IO.inspect(changeset, label: "Update Changeset")

      case Repo.update(changeset) do
        {:ok, updated_user} ->
          IO.puts("User updated successfully: #{inspect(updated_user)}")
          {:ok, updated_user}

        {:error, changeset} ->
          IO.puts("Failed to update user.")
          IO.inspect(changeset.errors, label: "Changeset Errors")
          {:error, changeset}
      end
  end
end


end
