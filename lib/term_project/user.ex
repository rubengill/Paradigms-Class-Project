# defmodule TermProject.Accounts.User do
#   @table :users

#   # Initialize the ETS table
#   def init do
#     :ets.new(@table, [:set, :public, :named_table])
#   end

#   # Register a new user
#   def register_user(username, password) do
#     case :ets.lookup(@table, username) do
#       [] ->
#         hashed_password = Bcrypt.hash_pwd_salt(password)
#         :ets.insert(@table, {username, hashed_password})
#         {:ok, username}

#       _ ->
#         {:error, :user_exists}
#     end
#   end

#   # Authenticate a user
#   def authenticate_user(username, password) do
#     case :ets.lookup(@table, username) do
#       [{^username, hashed_password}] ->
#         if Bcrypt.verify_pass(password, hashed_password) do
#           {:ok, username}
#         else
#           {:error, :invalid_credentials}
#         end

#       [] ->
#         {:error, :user_not_found}
#     end
#   end

#   # Guests
#   def add_guest(guest_name) do
#     :ets.insert(:users, {:guest, guest_name})
#   end

#   # Fetch all users
#   def list_users do
#     :ets.tab2list(@table)
#   end

#   # Fetch a specific user by username
#   def get_user(username) do
#     case :ets.lookup(@table, username) do
#       [] -> {:error, :not_found}
#       [{_key, value}] -> {:ok, value}
#     end
#   end
# end
