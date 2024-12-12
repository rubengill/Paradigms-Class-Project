defmodule TermProject.Accounts.LoginUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :full_name, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :token, :string
    field :auth_provider, :string, default: "regular"

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    IO.puts("from the changeset function")
    IO.inspect(attrs, label: "attrs")
    user
    |> cast(attrs, [:email, :full_name, :password, :token, :auth_provider])
    |> validate_required_fields(attrs)
    |> validate_email_format()
    |> validate_length(:password, min: 6, allow_nil: true) # Allow nil for OAuth users
    |> unique_constraint(:email)
    |> hash_password()
  end

  # Handles required fields based on the type of user
  defp validate_required_fields(changeset, attrs) do
    IO.puts("from the validate function attrs: #{inspect(attrs)}")
    IO.inspect(Map.get(attrs, "token"), label: "token")
    IO.inspect(Map.get(attrs, "password"), label: "password")
    IO.puts("LOOK ABOVE FOR NIL VALUE")
    case Map.get(attrs, "password") do
      nil -> # watch out how you add debugs, since there is piping happening here
        changeset
        |> validate_required([:email, :full_name, :token])
        # IO.puts("case nil") # uncomment to break everything

      _ ->
        changeset
        |> validate_required([:email, :full_name, :password])
        # IO.puts("case regular")

      # _ -> # Extendable for other OAuth providers # this is for fun :D
      #   changeset
      #   |> validate_required([:email, :token])
      #   # IO.puts("case _")
    end
  end

  # Ensure email format is valid
  defp validate_email_format(changeset) do
    changeset
    |> validate_format(:email, ~r/^[\w.%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/, message: "is invalid")
  end

  # Hash the password only for regular users
  defp hash_password(changeset) do
    case get_change(changeset, :password) do

      nil -> changeset
      password -> put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
    end
  end
end
