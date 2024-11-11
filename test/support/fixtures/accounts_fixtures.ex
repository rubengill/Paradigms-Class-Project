defmodule TermProject.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TermProject.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some email",
        name: "some name",
        password_hash: "some password_hash"
      })
      |> TermProject.Accounts.create_user()

    user
  end
end
