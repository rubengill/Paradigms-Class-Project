defmodule TermProject.Game.Unit do
  @moduledoc """
  Behaviour defining the interface for all unit types.
  """

  @callback init(opts :: keyword()) :: map()
  @callback move(unit :: map()) :: map()
  @callback attack(unit :: map(), target :: map()) :: {map(), map()}
  @callback in_range?(unit :: map(), target :: map()) :: boolean()
end
