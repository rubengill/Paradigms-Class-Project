defmodule TermProject.UnitStruct do
  @moduledoc """
  Base struct for all units in the game.
  """

  defstruct [
    :type,
    :health,
    :damage,
    :range,
    :position,
    :owner
  ]
end
