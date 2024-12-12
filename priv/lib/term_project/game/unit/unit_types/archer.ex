defmodule TermProject.Game.UnitTypes.Archer do
  @moduledoc """
  Archer unit implementation.
  """

  @behaviour TermProject.Game.Unit

  alias TermProject.Utils.Position

  @impl true
  def init(opts) do
    %{
      id: opts[:id],
      type: :archer,
      position: opts[:position],
      owner: opts[:owner],
      health: 75,
      damage: 15,
      speed: 0.8,
      range: 5.0
    }
  end

  @impl true
  def move(unit) do
    # Archers may have different movement logic
    target_position = Position.enemy_base(unit.owner)
    new_position = Position.move_towards(unit.position, target_position, unit.speed)
    %{unit | position: new_position}
  end

  @impl true
  def attack(unit, target) do
    new_target = %{target | health: target.health - unit.damage}
    {unit, new_target}
  end

  @impl true
  def in_range?(unit, target) do
    Position.distance(unit.position, target.position) <= unit.range
  end
end
