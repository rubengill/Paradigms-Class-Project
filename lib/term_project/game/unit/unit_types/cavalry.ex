defmodule TermProject.Units.Cavalry do
  @behaviour TermProject.Unit

  @type t :: %__MODULE__{
          type: atom(),
          health: integer(),
          damage: integer(),
          range: integer(),
          speed: integer()
        }

  defstruct type: :cavalry, health: 75, damage: 15, range: 2, speed: 3

  @impl true
  def type, do: :cavalry

  @impl true
  def stats do
    %{
      health: 75,
      damage: 15,
      range: 2,
      speed: 3
    }
  end

  @impl true
  def attack(target) do
    # Reduce target's health by the Cavalry's damage
    %{target | health: target.health - 15}
  end

  @impl true
  def in_range?({x1, y1}, {x2, y2}) do
    distance({x1, y1}, {x2, y2}) <= 2
  end

  defp distance({x1, y1}, {x2, y2}) do
    :math.sqrt(:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2))
  end
end
