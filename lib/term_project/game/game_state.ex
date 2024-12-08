defmodule TermProject.Game.GameState do
  defstruct units: [],
    players: %{},
    tick: 0,
    resources: %{
      1 => 100,  # Player 1 starting resources
      2 => 100   # Player 2 starting resources
    },
    bases: %{
      1 => %{health: 1000},
      2 => %{health: 1000}
    }
end
