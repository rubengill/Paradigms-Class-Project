defmodule TermProject.Units.Archer do
  @behaviour TermProject.Unit

  @type t :: %__MODULE__{
          type: atom(),
          health: integer(),
          damage: integer(),
          range: integer()
        }

  defstruct type: :archer, health: 50, damage: 10, range: 5

  @impl true
  def type, do: :archer

  @impl true
  def stats do
    %{
      health: 50,
      damage: 10,
      range: 5
    }
  end

  @impl true
  def attack(target) do
    # Reduce target's health by the Archer's damage
    %{target | health: target.health - 10}
  end

  @impl true
  def in_range?({x1, y1}, {x2, y2}) do
    distance({x1, y1}, {x2, y2}) <= 5
  end

  defp distance({x1, y1}, {x2, y2}) do
    :math.sqrt(:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2))
  end
end
