defmodule TermProject.Game.GameState do
  @moduledoc """
  Defines the GameState struct, which holds the entire game state.
  """

  defstruct units: [], players: %{}, tick: 0
end
