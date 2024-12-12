defmodule TermProject.Units.Knight do
  @behaviour TermProject.Unit

  @type t :: %__MODULE__{
          type: atom(),
          health: integer(),
          damage: integer(),
          range: integer()
        }

  defstruct type: :knight, health: 100, damage: 20, range: 1

  @impl true
  def type, do: :knight

  @impl true
  def stats do
    %{
      health: 100,
      damage: 20,
      range: 1
    }
  end

  @impl true
  def attack(target) do
    # Reduce target's health by the Knight's damage
    %{target | health: target.health - 20}
  end

  @impl true
  def in_range?({x1, y1}, {x2, y2}) do
    distance({x1, y1}, {x2, y2}) <= 1
  end

  defp distance({x1, y1}, {x2, y2}) do
    :math.sqrt(:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2))
  end
end
